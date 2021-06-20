# VLSI 

DC
综合包括： Synthesis = Translate + Mapping +Optimization


Translate:
将verilog转换为GTECH库的逻辑电路. GTECH库是Synopsys公司提供的通用的、独立于工艺的元件库.

命令：read_file -format verilog {./ConvArrayUnit.v}


Mapping:
这个步骤没什么印象，网上给的解释是“将GTECH映射到某一指定的工艺库，此网表包含了工艺参数”，但是在lab中没有遇到。
Optimization:
在增加约束之后,对网表进行优化。命令："compile"