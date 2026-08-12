package com.hmdp.service.impl;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hmdp.dto.Result;
import com.hmdp.entity.Shop;
import com.hmdp.mapper.ShopMapper;
import com.hmdp.service.IShopService;
import com.hmdp.utils.SystemConstants;
import org.springframework.data.geo.*;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.domain.geo.Metrics;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import static com.hmdp.utils.RedisConstants.*;

@Service
public class ShopServiceImpl extends ServiceImpl<ShopMapper, Shop> implements IShopService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public Result queryById(Long id) {
        String cacheKey = CACHE_SHOP_KEY + id;
        String json = stringRedisTemplate.opsForValue().get(cacheKey);
        if (json != null) {
            if (json.isEmpty()) {
                return Result.fail("商铺不存在");
            }
            return Result.ok(JSONUtil.toBean(json, Shop.class));
        }

        String lockKey = LOCK_SHOP_KEY + id;
        Boolean locked = Boolean.TRUE.equals(stringRedisTemplate.opsForValue()
                .setIfAbsent(lockKey, "1", LOCK_SHOP_TTL, TimeUnit.SECONDS));
        if (!locked) {
            return Result.fail("系统繁忙，请稍后重试");
        }
        try {
            json = stringRedisTemplate.opsForValue().get(cacheKey);
            if (json != null) {
                return json.isEmpty()
                        ? Result.fail("商铺不存在")
                        : Result.ok(JSONUtil.toBean(json, Shop.class));
            }
            Shop shop = getById(id);
            if (shop == null) {
                stringRedisTemplate.opsForValue().set(cacheKey, "", CACHE_NULL_TTL, TimeUnit.MINUTES);
                return Result.fail("商铺不存在");
            }
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

    @Override
    public Result update(Shop shop) {
        if (shop.getId() == null) {
            return Result.fail("id不能为空");
        }
        boolean updated = updateById(shop);
        return Result.ok(updated);
    }

    @Override
    public Result queryShopByType(Integer typeId, Integer current, Double x, Double y) {
        if (x == null || y == null) {
            Page<Shop> page = query()
                    .eq("type_id", typeId)
                    .page(new Page<>(current, SystemConstants.MAX_PAGE_SIZE));
            return Result.ok(page.getRecords());
        }

        int from = (current - 1) * SystemConstants.MAX_PAGE_SIZE;
        int end = current * SystemConstants.MAX_PAGE_SIZE;
        String key = SHOP_GEO_KEY + typeId;
        GeoResults<RedisGeoCommands.GeoLocation<String>> results = stringRedisTemplate.opsForGeo().radius(
                key,
                new Circle(new Point(x, y), new Distance(999999, Metrics.METERS)),
                RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs().includeDistance().limit(end)
        );
        if (results == null) {
            return Result.ok(Collections.emptyList());
        }

        List<GeoResult<RedisGeoCommands.GeoLocation<String>>> content = results.getContent();
        if (content.size() <= from) {
            return Result.ok(Collections.emptyList());
        }

        List<Long> ids = new ArrayList<>(content.size());
        Map<String, Distance> distanceMap = new HashMap<>();
        content.stream().skip(from).forEach(result -> {
            String shopId = result.getContent().getName();
            ids.add(Long.valueOf(shopId));
            distanceMap.put(shopId, result.getDistance());
        });

        if (ids.isEmpty()) {
            return Result.ok(Collections.emptyList());
        }

        String idStr = ids.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<Shop> shops = lambdaQuery()
                .in(Shop::getId, ids)
                .last("order by field(id," + idStr + ")")
                .list();
        for (Shop shop : shops) {
            Distance distance = distanceMap.get(shop.getId().toString());
            if (distance != null) {
                shop.setDistance(distance.getValue());
            }
        }
        return Result.ok(shops);
    }
}
