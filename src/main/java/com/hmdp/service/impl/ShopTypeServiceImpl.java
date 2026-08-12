package com.hmdp.service.impl;

import cn.hutool.json.JSONUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hmdp.dto.Result;
import com.hmdp.entity.ShopType;
import com.hmdp.mapper.ShopTypeMapper;
import com.hmdp.service.IShopTypeService;
import com.hmdp.utils.RedisConstants;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;

@Service
public class ShopTypeServiceImpl extends ServiceImpl<ShopTypeMapper, ShopType> implements IShopTypeService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Override
    public Result getTypeList() {
        String key = RedisConstants.CACHE_TYPE_KEY;
        Long size = stringRedisTemplate.opsForList().size(key);
        if (size != null && size > 0) {
            List<String> list = stringRedisTemplate.opsForList().range(key, 0, size - 1);
            List<ShopType> result = new ArrayList<>();
            if (list != null) {
                for (String json : list) {
                    result.add(JSONUtil.toBean(json, ShopType.class));
                }
            }
            return Result.ok(result);
        }

        List<ShopType> typeList = query().orderByAsc("sort").list();
        if (typeList == null || typeList.isEmpty()) {
            return Result.ok(new ArrayList<>());
        }
        List<String> jsonList = new ArrayList<>(typeList.size());
        for (ShopType shopType : typeList) {
            jsonList.add(JSONUtil.toJsonStr(shopType));
        }
        stringRedisTemplate.delete(key);
        stringRedisTemplate.opsForList().rightPushAll(key, jsonList);
        return Result.ok(typeList);
    }
}
