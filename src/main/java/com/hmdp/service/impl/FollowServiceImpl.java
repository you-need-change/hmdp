package com.hmdp.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hmdp.dto.Result;
import com.hmdp.dto.UserDTO;
import com.hmdp.entity.Follow;
import com.hmdp.entity.User;
import com.hmdp.mapper.FollowMapper;
import com.hmdp.service.IFollowService;
import com.hmdp.service.IUserService;
import com.hmdp.utils.RedisConstants;
import com.hmdp.utils.UserHolder;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class FollowServiceImpl extends ServiceImpl<FollowMapper, Follow> implements IFollowService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private IUserService userService;

    @Override
    @Transactional
    public Result follow(Long followUserId, Boolean isFollow) {
        UserDTO user = UserHolder.getUser();
        if (user == null || user.getId() == null) {
            return Result.fail("用户未登录");
        }
        if (user.getId().equals(followUserId)) {
            return Result.fail("不能关注自己");
        }

        String key = RedisConstants.FOLLOW_KEY + user.getId();
        if (Boolean.TRUE.equals(isFollow)) {
            long count = query()
                    .eq("user_id", user.getId())
                    .eq("follow_user_id", followUserId)
                    .count();
            if (count > 0) {
                return Result.ok();
            }
            Follow follow = new Follow();
            follow.setUserId(user.getId());
            follow.setFollowUserId(followUserId);
            boolean success = save(follow);
            if (success) {
                stringRedisTemplate.opsForSet().add(key, followUserId.toString());
            }
            return Result.ok();
        }

        boolean success = remove(new QueryWrapper<Follow>()
                .eq("user_id", user.getId())
                .eq("follow_user_id", followUserId));
        if (success) {
            stringRedisTemplate.opsForSet().remove(key, followUserId.toString());
        }
        return Result.ok();
    }

    @Override
    public Result isFollow(Long followUserId) {
        UserDTO user = UserHolder.getUser();
        if (user == null || user.getId() == null) {
            return Result.ok(false);
        }
        Long count = query()
                .eq("user_id", user.getId())
                .eq("follow_user_id", followUserId)
                .count();
        return Result.ok(count > 0);
    }

    @Override
    public Result followCommons(Long id) {
        UserDTO user = UserHolder.getUser();
        String key = RedisConstants.FOLLOW_KEY + user.getId();
        String otherKey = RedisConstants.FOLLOW_KEY + id;
        Set<String> intersect = stringRedisTemplate.opsForSet().intersect(key, otherKey);
        if (intersect == null || intersect.isEmpty()) {
            return Result.ok(new ArrayList<>());
        }
        List<Long> ids = intersect.stream().map(Long::valueOf).collect(Collectors.toList());
        List<UserDTO> users = userService.listByIds(ids).stream()
                .map(userEntity -> BeanUtil.copyProperties(userEntity, UserDTO.class))
                .collect(Collectors.toList());
        return Result.ok(users);
    }
}
