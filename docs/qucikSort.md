---
title: 快速排序
date: 2021-11-22
---

## 快速排序是必须掌握的排序算法之一，是冒泡排序的升级版

- 快速先找一个标记点，数组中任意一个，一般取数组里的第一个

- 经过第一次的遍历后，标记点左边的数，都比标记点小，右边都比标记点大

  - 一般数组的首项与末项作为left = 0,right = arr.length -1
  - 必须让left < right，要不然可以理解数组已经排序好
  - 遍及的逻辑还是比较难以理解的，通过下面的示意图理解
  - `lessMinPovit`意思是最小的比6(`例子中取6`)大的`数字`所在的`位置`,而不是`数字本身`

- 左右两边递归进行
  
  - 递归进行的，一定是标记点前后，而不是标记点本身。因为标记点已经排序好

```ts
const quickSort = (arr:number[],left?:number,right?:number) => {
    let len = arr.length;
    left = typeof left === 'number' ? left : 0;
    right = typeof right === 'number' ? right : len - 1;

    if(left < right) {
        let posiNumber = locationFn(arr,left,right);
        quickSort(arr,left,posiNumber - 1);
        quickSort(arr,posiNumber+1,right);
    }
}



// [6,9,5,7,2,12,45,21]    原始排序

// [6,5,9,7,2,12,45,21]    从9开始遍历，发现9>6,于是从5开始遍历,发现5<6,于是交换5，9

// [6,5,2,7,9,12,45,21]    从7继续遍历，发现7>6,于是2继续遍历,发现2<6,于是交换2，9

// 一直继续遍及发现后面的数都大于6，循环结束

// 循环结束后，发现7是最小的比6的的数，因此将7前面的数字2与6进行替换
// [2,5,6,7,9,12,45,21]

//返回6所在的位置，也就是lessMinPovit-1

const locationFn = (arr:number[],left:number,right:number) => {
    let povit = left;
    let lessMinPovit = povit + 1
    for(let i = lessMinPovit; i <= right; i ++) {
        if(arr[i] < arr[povit]) {
            swatch(arr,i,lessMinPovit);
            lessMinPovit++
        }
    }
   swatch(arr,povit,lessMinPovit - 1)
   return lessMinPovit - 1
}

const swatch  = (arr:number[],i:number,k:number) => {
   let temp = arr[i];
   arr[i] = arr[k];
   arr[k] = temp;
}

let cc = [45,6,3,1,34,56,78,44,234,987,112,432,664,11,54]

quickSort(cc)
```
