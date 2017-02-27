clear; clc; close all;

%读取图片
image = imread('images/10.jpg');
%提取指尖
result=finger(image);
