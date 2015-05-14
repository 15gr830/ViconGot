clc
close all
clear all

sample_rate = 50;
data = zeros(5);
q = zeros(4)';
load('test_aausat');

no = 1;
tic;
for n = 1:1000
   if n == (sample_rate * no) || n == 1;
       t = toc;
       q = Output_GetSegmentGlobalRotationQuaternion.Rotation;
       
       data(no,:) = [t q'];
       no = no + 1;
   end
end