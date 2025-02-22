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
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
}

.tags {
    display: flex;
    flex-wrap: wrap;
    margin-bottom: 20px;
    padding: 0 1rem 0 1rem;
    justify-content: space-between;
}

.tag {
    background: #eee;
    border-radius: 3px;
    padding: 5px 10px;
    margin: 5px;
    cursor: pointer;
}

.tag:hover {
    background: #ddd;
}

.posts {
    padding: 0 1rem 0 0;
}

.posts .post {
    margin-bottom: 20px;
    list-style: none;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
    transition: box-shadow 0.3s ease, background-color 0.3s ease;
}

.posts .post:hover {
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    background-color: #f9f9f9;
}

.post-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.post-title {
    flex: 1;
    margin-right: 10px;
}

.post-meta {
    flex: 2;
    font-size: 0.8em;
    color: #666;
    margin-right: 10px;
}

.post-tags {
    display: flex;
    flex-wrap: wrap;
}

.post-tag {
    background: #eee;
    border-radius: 3px;
    padding: 2px 5px;
    margin: 2px;
}
</style>