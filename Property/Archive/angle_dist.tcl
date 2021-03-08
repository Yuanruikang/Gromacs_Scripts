#获得要计算的帧数
set anglefile [open angle-SDPC.xvg w ]
set n [molinfo top get numframes]
puts $n
set sum 0.0
set c1 [atomselect top "( (resname SDPC and same residue as exwithin 5 of protein) and name C33) and resid 47 to 96"]
set c2 [atomselect top "( (resname SDPC and same residue as exwithin 5 of protein) and name C34) and resid 47 to 96"]
#每个C原子的所有帧循环
for { set frame 1 } { $frame < $n } { incr frame } {
	  #选择距离蛋白5A 以内的磷脂
    puts $frame
	  $c1 frame $frame
	  $c1 update
    $c2 frame $frame
	  $c2 update
	  #有num个磷脂分子被选中
	  #获得C原子坐标
    set c1x [$c1 get x]
    set c1y [$c1 get y]
    set c1z [$c1 get z]
	  #C-H坐标差
    set cxx [vecsub $c1x [$c2 get x]]
    set cxy [vecsub $c1y [$c2 get y]]
    set cxz [vecsub $c1z [$c2 get z]]
	  #计算与Z轴的夹角余弦平方
    foreach dx $cxx dy $cxy dz $cxz {
      set norm2 [expr {$dx*$dx + $dy*$dy + $dz*$dz}]
      set sum [expr {acos(sqrt($dz*$dz/$norm2)) * 180.0/3.141592653}]
    }
    if {$sum>90.0} {
      puts $anglefile [expr 180.0-$sum]
    } else {
        puts $anglefile "$sum"
    }
  }
close $anglefile
