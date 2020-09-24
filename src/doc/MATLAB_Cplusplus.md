# MATLAB与C++混合编程

Lu, Hong

## When

- 使用MATLAB 的使用场景
  - 矩阵、向量运算快速；
  - 特定的函数， 如 fft；
- 利用 MATLAB 的 extern 外部接口进行C++编程
  - 在程序无法向量化的时候（程序串行性较高）；
  - For-loop 很多无法避免的时候。



## Why

- 现有的丰富的 C/C++ 库；
- C++ 计算速度快，能突破一些瓶颈计算；
- 并行化，在C/C++中可以创建多线程计算，当然MATLAB也可以改造成 parfor等并行计算模式；



## What

- MATLAB 的函数模板

  ```MATLAB
  function [argout1, argout2,...] = FUNC(argin1, argin2,...)
  end
  ```

- MEX 接口目的就是使得 MATLAB 程序员能够以固有的方式调用 C/C++ 的代码
- MEX - MATLAB executable



## How

- 查看 MATLAB 编译器设置 
  - LInux - gcc 
  - Windows - MinGw

<img src="/home/leiws/.config/Typora/typora-user-images/image-20200413191506417.png" alt="image-20200413191506417" style="zoom: 67%;" />

- mex！

<img src="/home/leiws/.config/Typora/typora-user-images/image-20200413191851602.png" alt="image-20200413191851602" style="zoom:67%;" />



- **Example** 

<img src="/home/leiws/.config/Typora/typora-user-images/image-20200413200425090.png" alt="image-20200413200425090" style="zoom: 100%;" />

Unique 函数 MATLAB 执行 8.298092 秒， C++ 执行 1.662042 秒。

```C++
# include "mex.h"
# include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){

    double* input = mxGetPr(prhs[0]);
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double* output = mxGetPr(plhs[0]);
    size_t len = mxGetNumberOfElements(prhs[0]);

    *output = 0;

    double cache = *input;
    for (size_t i = 0; i < len; i++)
    {
        if (input[i] == cache)
        {
            continue;
        }
        else
        {
            cache = input[i];
            *output += 1;
        }
    }
}
```

**图解 MEX 计算流程**

![image-20200413205805166](/home/leiws/.config/Typora/typora-user-images/image-20200413205805166.png)

