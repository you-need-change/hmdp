package com.hmdp.config;

import com.hmdp.entity.Shop;
import com.hmdp.service.IShopService;
import com.hmdp.utils.RedisConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
@Slf4j
public class ShopGeoDataInitializer implements ApplicationRunner {

    @Resource
    private IShopService shopService;

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public void run(ApplicationArguments args) {
        try {
            List<Shop> shops = shopService.list();
            Map<Long, List<Shop>> byType = shops.stream()
                    .filter(shop -> shop.getTypeId() != null && shop.getX() != null && shop.getY() != null)
                    .collect(Collectors.groupingBy(Shop::getTypeId));
            for (Map.Entry<Long, List<Shop>> entry : byType.entrySet()) {
                String key = RedisConstants.SHOP_GEO_KEY + entry.getKey();
                for (Shop shop : entry.getValue()) {
                    stringRedisTemplate.opsForGeo()
                            .add(key, new Point(shop.getX(), shop.getY()), shop.getId().toString());
                }
            }
        } catch (Exception e) {
            log.warn("shop geo data initialization failed", e);
        }
    }
}
