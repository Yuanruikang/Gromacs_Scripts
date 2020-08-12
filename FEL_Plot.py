# -*- coding:utf-8 -*-

import pandas as pd

import matplotlib.pyplot as plt
import numpy as np

# 读取文件
file='fel_SDPC_gr_rm.txt'
data=pd.read_csv(file,sep='\t',header=None)
fesvalue=np.array(data[2])
plotvalue=np.reshape(fesvalue,(32,-1))

# 绘图
figure=plt.figure(figsize=(8,8))

plt.xlabel('PC1',fontsize=16)
plt.ylabel('PC2',fontsize=16)


plt.title(file)
im=plt.imshow(plotvalue,cmap='gist_rainbow',interpolation='bilinear')
plt.colorbar(im)

ax = plt.gca() 
ax.invert_yaxis()

#my_x_ticks = np.arange(-5, 5, 0.5)
#my_y_ticks = np.arange(-2, 2, 0.3)

#plt.xticks(my_x_ticks)
#plt.yticks(my_y_ticks)
plt.show()
#plt.savefig('fes.png',dpi=600)

