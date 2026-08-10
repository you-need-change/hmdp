package com.hmdp.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.hmdp.dto.Result;
import com.hmdp.dto.ScrollResult;
import com.hmdp.dto.UserDTO;
import com.hmdp.entity.Blog;
import com.hmdp.entity.Follow;
import com.hmdp.entity.User;
import com.hmdp.mapper.BlogMapper;
import com.hmdp.service.IBlogService;
import com.hmdp.service.IFollowService;
import com.hmdp.service.IUserService;
import com.hmdp.utils.RedisConstants;
import com.hmdp.utils.SystemConstants;
import com.hmdp.utils.UserHolder;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class BlogServiceImpl extends ServiceImpl<BlogMapper, Blog> implements IBlogService {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    @Resource
    private IUserService userService;

    @Resource
    private IFollowService followService;

    @Override
    public Result saveBlog(Blog blog) {
        UserDTO user = UserHolder.getUser();
        blog.setId(null);
        blog.setUserId(user.getId());
        blog.setLiked(0);
        blog.setComments(0);
        save(blog);

        List<Follow> followers = followService.query()
                .eq("follow_user_id", user.getId())
                .list();
        for (Follow follow : followers) {
            String key = RedisConstants.FEED_KEY + follow.getUserId();
            stringRedisTemplate.opsForZSet().add(key, blog.getId().toString(), System.currentTimeMillis());
        }
        return Result.ok(blog.getId());
    }

    @Override
    public Result queryBlogById(Long id) {
        Blog blog = getById(id);
        if (blog == null) {
            return Result.fail("博客不存在");
        }
        fillUser(blog);
        isBlogLiked(blog);
        return Result.ok(blog);
    }

    @Override
    public Result queryHotBlog(Integer current) {
        Page<Blog> page = query()
                .orderByDesc("liked")
                .orderByDesc("create_time")
                .page(new Page<>(current, SystemConstants.MAX_PAGE_SIZE));
        List<Blog> records = page.getRecords();
        records.forEach(blog -> {
            fillUser(blog);
            isBlogLiked(blog);
        });
        return Result.ok(records);
    }

    @Override
    public Result queryMyBlog(Integer current) {
        UserDTO user = UserHolder.getUser();
        Page<Blog> page = query()
                .eq("user_id", user.getId())
                .orderByDesc("create_time")
                .page(new Page<>(current, SystemConstants.MAX_PAGE_SIZE));
        List<Blog> records = page.getRecords();
        records.forEach(this::fillUser);
        return Result.ok(records);
    }

    @Override
    public Result likeBlog(Long id) {
        UserDTO user = UserHolder.getUser();
        Blog blog = getById(id);
        if (blog == null) {
            return Result.fail("博客不存在");
        }

        String key = RedisConstants.BLOG_LIKED_KEY + id;
        String userId = user.getId().toString();
        Double score = stringRedisTemplate.opsForZSet().score(key, userId);
        if (score != null) {
            stringRedisTemplate.opsForZSet().remove(key, userId);
            update().setSql("liked = greatest(liked - 1, 0)").eq("id", id).update();
            return Result.ok(false);
        }

        stringRedisTemplate.opsForZSet().add(key, userId, System.currentTimeMillis());
        update().setSql("liked = liked + 1").eq("id", id).update();
        return Result.ok(true);
    }

    @Override
    public Result queryBlogLikes(Long id) {
        String key = RedisConstants.BLOG_LIKED_KEY + id;
        Set<String> top5 = stringRedisTemplate.opsForZSet().range(key, 0, 4);
        if (top5 == null || top5.isEmpty()) {
            return Result.ok(new ArrayList<>());
        }
        List<Long> ids = top5.stream().map(Long::valueOf).collect(Collectors.toList());
        String idStr = ids.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<UserDTO> users = userService.query()
                .in("id", ids)
                .last("order by field(id," + idStr + ")")
                .list()
                .stream()
                .map(user -> BeanUtil.copyProperties(user, UserDTO.class))
                .collect(Collectors.toList());
        return Result.ok(users);
    }

    @Override
    public Result queryBlogOfFollow(Long max, Integer offset) {
        UserDTO user = UserHolder.getUser();
        String key = RedisConstants.FEED_KEY + user.getId();
        Set<ZSetOperations.TypedTuple<String>> typedTuples = stringRedisTemplate.opsForZSet()
                .reverseRangeByScoreWithScores(key, 0, max, offset, SystemConstants.DEFAULT_PAGE_SIZE);
        if (typedTuples == null || typedTuples.isEmpty()) {
            return Result.ok(new ScrollResult());
        }

            List<Long> ids = new ArrayList<>(typedTuples.size());
        long minTime = 0;
        int os = 1;
        for (ZSetOperations.TypedTuple<String> tuple : typedTuples) {
            ids.add(Long.valueOf(tuple.getValue()));
            long time = tuple.getScore().longValue();
            if (time == minTime) {
                os++;
            } else {
                minTime = time;
                os = 1;
            }
        }

        String idStr = ids.stream().map(String::valueOf).collect(Collectors.joining(","));
        List<Blog> blogs = query()
                .in("id", ids)
                .last("order by field(id," + idStr + ")")
                .list();
        blogs.forEach(blog -> {
            fillUser(blog);
            isBlogLiked(blog);
        });

        ScrollResult result = new ScrollResult();
        result.setList(blogs);
        result.setMinTime(minTime);
        result.setOffset(os);
        return Result.ok(result);
    }

    private void fillUser(Blog blog) {
        User user = userService.getById(blog.getUserId());
        if (user != null) {
            blog.setName(user.getNickName());
            blog.setIcon(user.getIcon());
        }
    }

    private void isBlogLiked(Blog blog) {
        UserDTO user = UserHolder.getUser();
        if (user == null || user.getId() == null) {
            blog.setIsLike(false);
            return;
        }
        String key = RedisConstants.BLOG_LIKED_KEY + blog.getId();
        blog.setIsLike(stringRedisTemplate.opsForZSet().score(key, user.getId().toString()) != null);
    }
}
