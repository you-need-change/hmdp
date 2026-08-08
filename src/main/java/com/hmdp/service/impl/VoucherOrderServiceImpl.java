package com.hmdp.service.impl;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hmdp.dto.Result;
import com.hmdp.dto.UserDTO;
import com.hmdp.entity.SeckillVoucher;
import com.hmdp.entity.VoucherOrder;
import com.hmdp.mapper.VoucherOrderMapper;
import com.hmdp.service.ISeckillVoucherService;
import com.hmdp.service.IVoucherOrderService;
import com.hmdp.utils.RedisConstants;
import com.hmdp.utils.UserHolder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.connection.stream.Consumer;
import org.springframework.data.redis.connection.stream.MapRecord;
import org.springframework.data.redis.connection.stream.ReadOffset;
import org.springframework.data.redis.connection.stream.StreamOffset;
import org.springframework.data.redis.connection.stream.StreamReadOptions;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Slf4j
@Service
public class VoucherOrderServiceImpl
        extends ServiceImpl<VoucherOrderMapper, VoucherOrder>
        implements IVoucherOrderService {

    private static final DefaultRedisScript<Long> SECKILL_SCRIPT;
    private static final ExecutorService SECKILL_ORDER_EXECUTOR = Executors.newSingleThreadExecutor();
    private static final String GROUP_NAME = "g1";
    private static final String CONSUMER_NAME = "c1";

    static {
        SECKILL_SCRIPT = new DefaultRedisScript<>();
        SECKILL_SCRIPT.setLocation(new ClassPathResource("seckill.lua"));
        SECKILL_SCRIPT.setResultType(Long.class);
    }

    @Resource
    private ISeckillVoucherService seckillVoucherService;

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private TransactionTemplate transactionTemplate;

    @PostConstruct
    private void init() {
        try {
            stringRedisTemplate.opsForStream()
                    .createGroup(RedisConstants.STREAM_ORDERS_KEY, ReadOffset.from("0"), GROUP_NAME);
        } catch (Exception e) {
            log.debug("stream group already exists or cannot be created", e);
        }
        SECKILL_ORDER_EXECUTOR.submit(new VoucherOrderHandler());
    }

    @Override
    public Result seckillVoucher(Long voucherId) {
        UserDTO user = UserHolder.getUser();
        if (user == null || user.getId() == null) {
            return Result.fail("用户未登录");
        }

        SeckillVoucher voucher = seckillVoucherService.getById(voucherId);
        if (voucher == null) {
            return Result.fail("优惠券不存在");
        }

        LocalDateTime now = LocalDateTime.now();
        if (voucher.getBeginTime() != null && voucher.getBeginTime().isAfter(now)) {
            return Result.fail("秒杀尚未开始");
        }
        if (voucher.getEndTime() != null && voucher.getEndTime().isBefore(now)) {
            return Result.fail("秒杀已经结束");
        }

        Long orderId = IdUtil.getSnowflakeNextId();
        Long result = stringRedisTemplate.execute(
                SECKILL_SCRIPT,
                Collections.emptyList(),
                voucherId.toString(),
                user.getId().toString(),
                orderId.toString());
        if (result == null) {
            return Result.fail("秒杀失败");
        }

        int code = result.intValue();
        if (code == 1) {
            return Result.fail("库存不足");
        }
        if (code == 2) {
            return Result.fail("不能重复下单");
        }
        return Result.ok(orderId);
    }

    private void handleVoucherOrder(VoucherOrder voucherOrder) {
        transactionTemplate.execute(status -> {
            Long userId = voucherOrder.getUserId();
            synchronized (String.valueOf(userId).intern()) {
                long count = query()
                        .eq("user_id", userId)
                        .eq("voucher_id", voucherOrder.getVoucherId())
                        .count();
                if (count > 0) {
                    log.warn("用户已经下单过一次，userId={}, voucherId={}", userId, voucherOrder.getVoucherId());
                    return null;
                }

                boolean success = seckillVoucherService.update()
                        .setSql("stock = stock - 1")
                        .eq("voucher_id", voucherOrder.getVoucherId())
                        .gt("stock", 0)
                        .update();
                if (!success) {
                    log.warn("库存不足，userId={}, voucherId={}", userId, voucherOrder.getVoucherId());
                    return null;
                }

                voucherOrder.setPayType(1);
                voucherOrder.setStatus(1);
                save(voucherOrder);
            }
            return null;
        });
    }

    private VoucherOrder mapToVoucherOrder(Map<Object, Object> value) {
        VoucherOrder voucherOrder = new VoucherOrder();
        voucherOrder.setId(Long.valueOf(value.get("id").toString()));
        voucherOrder.setUserId(Long.valueOf(value.get("userId").toString()));
        voucherOrder.setVoucherId(Long.valueOf(value.get("voucherId").toString()));
        return voucherOrder;
    }

    private class VoucherOrderHandler implements Runnable {
        @Override
        public void run() {
            while (true) {
                try {
                    List<MapRecord<String, Object, Object>> list = stringRedisTemplate.opsForStream().read(
                            Consumer.from(GROUP_NAME, CONSUMER_NAME),
                            StreamReadOptions.empty().count(1).block(Duration.ofSeconds(2)),
                            StreamOffset.create(RedisConstants.STREAM_ORDERS_KEY, ReadOffset.lastConsumed())
                    );
                    if (list == null || list.isEmpty()) {
                        continue;
                    }

                    MapRecord<String, Object, Object> record = list.get(0);
                    handleVoucherOrder(mapToVoucherOrder(record.getValue()));
                    stringRedisTemplate.opsForStream()
                            .acknowledge(RedisConstants.STREAM_ORDERS_KEY, GROUP_NAME, record.getId());
                } catch (Exception e) {
                    log.error("处理秒杀订单异常", e);
                    handlePendingList();
                }
            }
        }

        private void handlePendingList() {
            while (true) {
                try {
                    List<MapRecord<String, Object, Object>> list = stringRedisTemplate.opsForStream().read(
                            Consumer.from(GROUP_NAME, CONSUMER_NAME),
                            StreamReadOptions.empty().count(1),
                            StreamOffset.create(RedisConstants.STREAM_ORDERS_KEY, ReadOffset.from("0"))
                    );
                    if (list == null || list.isEmpty()) {
                        break;
                    }

                    MapRecord<String, Object, Object> record = list.get(0);
                    handleVoucherOrder(mapToVoucherOrder(record.getValue()));
                    stringRedisTemplate.opsForStream()
                            .acknowledge(RedisConstants.STREAM_ORDERS_KEY, GROUP_NAME, record.getId());
                } catch (Exception e) {
                    log.error("处理 pending-list 秒杀订单异常", e);
                    try {
                        Thread.sleep(50);
                    } catch (InterruptedException ex) {
                        Thread.currentThread().interrupt();
                        break;
                    }
                }
            }
        }
    }
}
