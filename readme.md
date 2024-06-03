# 全面展示多变量相关性关系

#### 1. 数据

- 文章提供了原始绘图数据，我摘取了绘制这个图相关的数据，需要更多数据的可以去文章中下载

#### 2. 相关性热图（大图）

- colorRampPalette() 定义渐变色，corrplot 中蓝色为正相关，红色为负相关，这跟我们通常做的相反，这里是对调热图的颜色条。
- cor() 函数用于计算数据的相关性。对于大范围的数据值，先将数据转换为对数尺度，有助于减小数据的差异性，更好地展示数据的特征。
-  corrplot()\$corrPos\$xName %>% unique 获取变量在热图上的排列顺序 。
- dev.new() 和 layout() 打开一个新的图形设备，并设置布局，用于保存接下来的大小相关性热图
- corrplot() 函数绘制热图，col = rev(colbar(200) 对调蓝红色，tl.col = variable_color 给变量设置颜色。

#### 3. 相关性热图（小图）

- rowSums() 对各分组的变量求和得到各组的数据，然后计算相关性，绘制组的相关性热图 。
- 因为 corrplot 的输出是矩阵，而不是图形对象，p = recordPlot() 是将当前绘图设备中的绘图信息保存起来。

#### 4. 边缘条形图

- summarise() 函数计算每个组中的均值，并将其对数化。
- mutate(bile_acid = factor(bile_acid, levels = rev(variable_ordering)), color = ifelse(bile_acid %in% abs_conc, "green", "purple")) 使用mutate() 函数添加 "color" 和 "bile_acid" 列。使用 factor() 定义因子顺序，这样能保证条形图的顺序与热图中的变量顺序一致，并为 "color" 列根据条件赋值。
- geom_col() 画条形图

#### 5. 添加图例

- data.frame() 自定义一个数据框，创建绘图区域

- geom_rect() 和 annotate() 分别用于创建图例的图形和文本，相对位置可以根据需要自由设置坐标。

#### 6. 组合图

- grid::viewport() 函数可以将条形图按照给定的尺寸和位置插入到主图中，比较好操作。

#### 

### 最重要的是：

码代码不易，如果你觉得我的教程对你有帮助，请<font face="微软雅黑" size=6 color=#FF0000 >**小红书 - Ttian6688**</font>关注我！！！
