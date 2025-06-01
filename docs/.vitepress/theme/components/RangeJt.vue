<!-- 生成一个按钮，点击展示两个随机数据 ，第一个是第x季，第二个第y期-->
<template>
    <div class="range-jt">
        <div class="range-jt__item">
            <span class="range-jt__label">第{{ x }}季</span>
        </div>
        <div class="range-jt__item">
            <span class="range-jt__label">第{{ y }}期</span>
        </div>  
        <!-- 按钮 -->
        <button class="range-jt__button" @click="randomRange">
            随机生成
        </button>
    </div>
</template>
<script setup lang="ts">
import { onMounted, ref } from 'vue';


const x = ref(1);
const y = ref(1);

function randomRange() {
    // x的范围是 1-4 
    x.value = Math.floor(Math.random() * 4) + 1;
    // y的范围是 1-12
    y.value = Math.floor(Math.random() * 12) + 1;
}


</script>
<style scoped>
.range-jt {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
}

.range-jt__item {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.range-jt__label {
    font-size: 16px;
    color: #333;
}

.range-jt__button {
    padding: 5px 10px;
    font-size: 14px;
    color: #fff;
    background-color: #007bff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

.range-jt__button:hover {
    background-color: #0056b3;
}

.range-jt__button:active {
    background-color: #004085;
}

.range-jt__button:focus {
    outline: none;
}

.range-jt__button:disabled {
    background-color: #ccc;
    cursor: not-allowed;
}

.range-jt__button:disabled:hover {
    background-color: #ccc;
}

.range-jt__button:disabled:active {
    background-color: #ccc;
}

.range-jt__button:disabled:focus {
    outline: none;
}

.range-jt__button:disabled {
    opacity: 0.5;
}

.range-jt__button:disabled:hover {
    background-color: #ccc;
}

.range-jt__button:disabled:active {
    background-color: #ccc;
}

.range-jt__button:disabled:focus {
    outline: none;
}

.range-jt__button:disabled {
    cursor: not-allowed;
}

.range-jt__button:disabled:hover {
    background-color: #ccc;
}

.range-jt__button:disabled:active {
    background-color: #ccc;
}

.range-jt__button:disabled:focus {
    outline: none;
}
</style>