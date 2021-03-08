#!/bin/bash
read -p "Please input the name" name
awk 'BEGIN{g[1]=0;g[2]=0;g[3]=0;g[4]=0;g[5]=0;g[6]=0;g[7]=0;g[8]=0;g[9]=0;g[10]=0;g[11]=0}
{for(i=1;i<=NF;i++)
   {
       split($i,a,"");
       for(k=1;k<=11;k++) 
         if(a[k]=="S" || a[k]=="T") 
           g[k]++ ;
       print a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11]}
}
END{for(k=1;k<=11;k++){print g[k]}}' ssdump.dat >> ${name}_ss_AA.dat

