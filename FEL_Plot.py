# -*- coding:utf-8 -*-

import pandas as pd

import matplotlib.pyplot as plt
import numpy as np

# 读取文件
data=pd.read_csv('fel_SDPC_4.txt',sep='\t',header=None)
fesvalue=np.array(data[2])
plotvalue=np.reshape(fesvalue,(32,-1))

# 绘图
plt.figure(figsize=(8,8))
im=plt.imshow(plotvalue,cmap='gist_rainbow_r',interpolation='bilinear')

#plt.yticks(im,np.arange(0, 4, 5))
#plt.xticks(im,np.arange(0, 2, 1))

plt.xlabel('PC1',fontsize=16)
plt.ylabel('PC2',fontsize=16)

plt.colorbar(im)
plt.show()
#plt.savefig('fes.png',dpi=600)

