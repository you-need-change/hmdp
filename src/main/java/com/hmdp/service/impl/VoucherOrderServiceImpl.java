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
import com.hmdp.utils.UserHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;

import javax.annotation.Resource;
import java.time.LocalDateTime;

@Service
public class VoucherOrderServiceImpl
        extends ServiceImpl<VoucherOrderMapper, VoucherOrder>
        implements IVoucherOrderService {

    @Resource
    private ISeckillVoucherService seckillVoucherService;

    @Resource
    private TransactionTemplate transactionTemplate;

    @Override
    public Result seckillVoucher(Long voucherId) {
        UserDTO user = UserHolder.getUser();
        if (user == null || user.getId() == null) {
            return Result.fail("用户未登录");
        }

        String lock = (user.getId() + ":" + voucherId).intern();
        synchronized (lock) {
            return transactionTemplate.execute(status -> createVoucherOrder(voucherId, user.getId()));
        }
    }

    private Result createVoucherOrder(Long voucherId, Long userId) {
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
        if (voucher.getStock() == null || voucher.getStock() < 1) {
            return Result.fail("库存不足");
        }

        long count = query()
                .eq("user_id", userId)
                .eq("voucher_id", voucherId)
                .count();
        if (count > 0) {
            return Result.fail("不能重复下单");
        }

        boolean success = seckillVoucherService.update()
                .setSql("stock = stock - 1")
                .eq("voucher_id", voucherId)
                .gt("stock", 0)
                .update();
        if (!success) {
            return Result.fail("库存不足");
        }

        VoucherOrder order = new VoucherOrder();
        order.setId(IdUtil.getSnowflakeNextId());
        order.setUserId(userId);
        order.setVoucherId(voucherId);
        order.setPayType(1);
        order.setStatus(1);
        save(order);
        return Result.ok(order.getId());
    }
}
