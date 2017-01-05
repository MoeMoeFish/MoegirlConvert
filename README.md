
MoegirlConvert
==============
用于 萌娘百科的图片缩略图转换

## Rule
* 判断图片类型
  * 如果是jpg/jpeg/png
    * 是否大于10K
      * 是，使用 -resize -quality 85% -interlace line 生成渐进式图片progressive jpeg
      * 否， -resize 缩图
  * 如果是gif，判断有多少帧
    * 小于等于10帧的gif，缩动图
    * 大于10帧的gif，只缩第一张图
  * 其他类型图片，直接缩图
* 判断缩小的图片是否大于等于300px
  * 是，添加图片水印
  * 否，不加水印

## 使用方法
`mgConvert.sh /path/source /path/destination width height /path/water`

在 mediawiki 系统中，可以将 `mgConvert.sh` 用于 `$wgCustomConvertCommand` 变量并使用变量替换上面的参数，例如

`$wgCustomConvertCommand = "/var/html/mediawiki/extensions/MoegirlConvert/mgConvert.sh %s %d %w %h /var/html/mediawiki/extensions/MoegirlConvert/water.png";`

## 注意事项
* `convert` 对内存需求比较大，应将 `$wgMaxShellMemory` 设置大一些
* 需要给 mgConvert.sh 设置运行权限


