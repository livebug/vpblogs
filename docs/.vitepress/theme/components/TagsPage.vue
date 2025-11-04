<template>
    <div class="container">
        <h1 style="text-align: center;">标签页</h1>
        <hr />
        <div class="tags">
            <span v-for="tag in uniqueTags" :key="tag" @click="filterByTag(tag)" class="tag">
                {{ tag.toLocaleLowerCase() }}
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
import { data as postsData } from '../../post.data';

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
    const unique = [...new Set(tags)];

    return unique.sort((a, b) => a.localeCompare(b));
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
    background: var(--vp-c-bg-soft);
    border-radius: 12px;
    box-shadow: var(--vp-shadow-1);
    border: 1px solid var(--vp-c-border);
}

.tags {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 28px;
    justify-content: flex-start;
}

.tag {
    background: var(--vp-button);
    color: var(--vp-c-text-1);
    border-radius: 10px;
    padding: 0px 6px;
    font-size: 1em;
    margin: 0;
    cursor: pointer;
    transition: background 0.2s, transform 0.1s, color 0.2s;
    box-shadow: var(--vp-shadow-1);
    user-select: none;
    border: 1px solid var(--vp-c-brand);
}

.tag:hover,
.tag.active {
    background: var(--vp-c-brand);
    color: var(--vp-c-white);
    transform: translateY(-2px) scale(1.05);
    box-shadow: var(--vp-shadow-2);
}

.posts {
    padding: 0;
}

.posts .post {
    margin-bottom: 20px;
    list-style: none;
    padding: 18px 20px;
    border: 1px solid var(--vp-c-border);
    border-radius: 8px;
    background: var(--vp-c-bg-soft);
    transition: box-shadow 0.2s, background 0.2s, border-color 0.2s;
    box-shadow: var(--vp-shadow-1);
}

.posts .post:hover {
    box-shadow: var(--vp-shadow-2);
    background: var(--vp-c-bg-soft-up);
    border-color: var(--vp-c-brand);
}

.post-content {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.post-title {
    font-weight: 600;
    font-size: 1.13em;
    color: var(--vp-c-brand);
    text-decoration: none;
    margin-bottom: 2px;
    transition: color 0.2s;
}

.post-title:hover {
    color: var(--vp-c-brand-dark);
    text-decoration: underline;
}

.post-meta {
    font-size: 0.85em;
    color: var(--vp-c-text-2);
    margin-bottom: 4px;
}

.post-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
}

.post-tag {
    background: var(--vp-c-brand-soft);
    color: var(--vp-c-brand);
    border-radius: 10px;
    padding: 2px 10px;
    margin-right: 4px;
    font-size: 0.65em;
    transition: background 0.2s, color 0.2s;
    border: 1px solid var(--vp-c-brand-soft);
}

.post-tag:hover {
    background: var(--vp-c-brand);
    color: var(--vp-c-white);
    border-color: var(--vp-c-brand);
}
</style>
