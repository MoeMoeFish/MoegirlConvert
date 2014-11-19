MoegirlConvert
==============
用于 萌娘百科的图片缩略图转换

## Rule
* 如果是 png, jpg 或单页的 gif, 直接缩图加水印
* 如果是 gif 动图且小于 10 帧，缩图也为 gif 动图并加水印
* 如果是 gif 动图且大于 10 帧，将 gif 的第 1 帧缩图并加水印，并在右上角加上 gif 标志，提示此图点开为动图

## 使用方法
`mgConvert.sh /path/source /path/destination width height /path/water`

在 mediawiki 系统中，可以将 `mgConvert.sh` 用于 `$wgCustomConvertCommand` 变量并使用变量替换上面的参数，如

`$wgCustomConvertCommand = "/var/html/mediawiki/extensions/MoegirlConvert/mgConvert.sh %s %d %w %h /var/html/mediawiki/extensions/MoegirlConvert/water.png";`



