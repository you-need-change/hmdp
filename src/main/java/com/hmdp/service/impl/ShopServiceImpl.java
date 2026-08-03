package com.hmdp.service.impl;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hmdp.dto.Result;
import com.hmdp.entity.Shop;
import com.hmdp.mapper.ShopMapper;
import com.hmdp.service.IShopService;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.concurrent.TimeUnit;

import static com.hmdp.utils.RedisConstants.*;

@Service
public class ShopServiceImpl extends ServiceImpl<ShopMapper, Shop> implements IShopService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public Result queryById(Long id) {
        String cacheKey = CACHE_SHOP_KEY + id;

        // 1. 尝试从缓存获取
        String json = stringRedisTemplate.opsForValue().get(cacheKey);
        if (json != null) {
            return json.isEmpty()
                    ? Result.fail("商铺不存在")
                    : Result.ok(JSONUtil.toBean(json, Shop.class));
        }

        // 2. 获取分布式锁
        String lockKey = LOCK_SHOP_KEY + id;
        Boolean locked = Boolean.TRUE.equals(stringRedisTemplate.opsForValue()
                .setIfAbsent(lockKey, "1", LOCK_SHOP_TTL, TimeUnit.SECONDS));
        if (!locked) {
            return Result.fail("系统繁忙，请稍后重试");
        }

        try {
            // 3. 双重检查缓存（避免重复查询数据库）
            json = stringRedisTemplate.opsForValue().get(cacheKey);
            if (json != null) {
                return json.isEmpty()
                        ? Result.fail("商铺不存在")
                        : Result.ok(JSONUtil.toBean(json, Shop.class));
            }

            // 4. 查询数据库
            Shop shop = getById(id);
            if (shop == null) {
                // 缓存空值，解决缓存穿透
                stringRedisTemplate.opsForValue().set(cacheKey, "", CACHE_NULL_TTL, TimeUnit.MINUTES);
                return Result.fail("商铺不存在");
            }

            // 5. 缓存商铺数据
            stringRedisTemplate.opsForValue().set(
                    cacheKey, JSONUtil.toJsonStr(shop), CACHE_SHOP_TTL, TimeUnit.MINUTES);
            return Result.ok(shop);
        } finally {
            stringRedisTemplate.delete(lockKey);
        }
    }

    @Override
    public boolean updateById(Shop entity) {
        boolean updated = super.updateById(entity);
        if (updated && entity.getId() != null) {
            stringRedisTemplate.delete(CACHE_SHOP_KEY + entity.getId());
        }
        return updated;
    }
}
