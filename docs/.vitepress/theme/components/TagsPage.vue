<template>
    <div class="container">
        <h1 style="text-align: center;">标签页</h1>
        <hr />
        <div class="tags">
            <span v-for="tag in uniqueTags" :key="tag" @click="filterByTag(tag)" class="tag">
                {{ tag }}
            </span>
        </div>
        <div class="posts">
            <ul>
                <li v-for="post in filteredPosts" :key="post.url" class="post">
                    <div class="post-content">
                        <a :href="post.url" class="post-title">{{ post.title }}</a>
                        <small class="post-meta">{{ post.dir }}</small>
                        <div class="post-tags">
                            <small>
                                <span v-for="tag in post.tags" :key="tag" class="post-tag">
                                    {{ tag }}

                                </span>
                            </small>
                        </div>
                    </div>
                </li>
            </ul>
        </div>
    </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue';
import { useRoute } from 'vitepress';
import { data as postsData } from '../post.data';

const selectedTag = ref(null);
const route = useRoute();

onMounted(() => {
    const queryTag = new URLSearchParams(window.location.search);
    if (queryTag.get('tag')) {
        selectedTag.value = queryTag.get('tag');
    }
});

const uniqueTags = computed(() => {
    const tags = postsData.flatMap(post => post.tags);
    return [...new Set(tags)];
});

const filteredPosts = computed(() => {
    if (!selectedTag.value) {
        return postsData;
    }
    return postsData.filter(post => post.tags.includes(selectedTag.value));
});

function filterByTag(tag) {
    selectedTag.value = tag;
}
</script>

<style scoped>
.container {
    margin: 40px auto;
    padding: 32px 24px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 16px rgba(60, 60, 60, 0.08);
}

.tags {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 28px;
    justify-content: flex-start;
}

.tag {
    background: #42b883;
    color: #fff;
    border-radius: 16px;
    padding: 6px 16px;
    font-size: 0.98em;
    margin: 0;
    cursor: pointer;
    transition: background 0.2s, transform 0.2s;
    box-shadow: 0 1px 4px rgba(66, 184, 131, 0.08);
    user-select: none;
}

.tag:hover, .tag.active {
    background: #35495e;
    color: #fff;
    transform: translateY(-2px) scale(1.05);
}

.posts {
    padding: 0;
}

.posts .post {
    margin-bottom: 20px;
    list-style: none;
    padding: 18px 20px;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    background: #f8fafc;
    transition: box-shadow 0.2s, background 0.2s;
    box-shadow: 0 1px 6px rgba(60, 60, 60, 0.04);
}

.posts .post:hover {
    box-shadow: 0 4px 16px rgba(60, 60, 60, 0.10);
    background: #f3f7fa;
}

.post-content {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.post-title {
    font-weight: 600;
    font-size: 1.13em;
    color: #42b883;
    text-decoration: none;
    margin-bottom: 2px;
    transition: color 0.2s;
}

.post-title:hover {
    color: #35495e;
    text-decoration: underline;
}

.post-meta {
    font-size: 0.85em;
    color: #888;
    margin-bottom: 4px;
}

.post-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
}

.post-tag {
    background: #e0f5ef;
    color: #42b883;
    border-radius: 10px;
    padding: 2px 10px;
    font-size: 0.85em;
    margin: 0;
    transition: background 0.2s, color 0.2s;
}

.post-tag:hover {
    background: #42b883;
    color: #fff;
}
</style>