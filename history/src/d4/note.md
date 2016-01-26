首先，你需要知道的是所谓对象文件(Object files)有三个种类：

1) 可重定位的对象文件(Relocatable file)

这是由汇编器汇编生成的 .o 文件。后面的链接器(link editor)拿一个或一些 Relocatable object files 作为输入，经链接处理后，生成一个可执行的对象文件 (Executable file) 或者一个可被共享的对象文件(Shared object file)。我们可以使用 ar 工具将众多的 .o Relocatable object files 归档(archive)成 .a 静态库文件。如何产生 Relocatable file，你应该很熟悉了，请参见我们相关的基本概念文章和JulWiki。另外，可以预先告诉大家的是我们的内核可加载模块 .ko 文件也是 Relocatable object file。

2) 可执行的对象文件(Executable file)

这我们见的多了。文本编辑器vi、调式用的工具gdb、播放mp3歌曲的软件mplayer等等都是Executable object file。你应该已经知道，在我们的 Linux 系统里面，存在两种可执行的东西。除了这里说的 Executable object file，另外一种就是可执行的脚本(如shell脚本)。注意这些脚本不是 Executable object file，它们只是文本文件，但是执行这些脚本所用的解释器就是 Executable object file，比如 bash shell 程序。

3) 可被共享的对象文件(Shared object file)

这些就是所谓的动态库文件，也即 .so 文件。如果拿前面的静态库来生成可执行程序，那每个生成的可执行程序中都会有一份库代码的拷贝。如果在磁盘中存储这些可执行程序，那就会占用额外的磁盘空间；另外如果拿它们放到Linux系统上一起运行，也会浪费掉宝贵的物理内存。如果将静态库换成动态库，那么这些问题都不会出现。动态库在发挥作用的过程中，必须经过两个步骤：

a) 链接编辑器(link editor)拿它和其他Relocatable object file以及其他shared object file作为输入，经链接处理后，生存另外的 shared object file 或者 executable file。

b) 在运行时，动态链接器(dynamic linker)拿它和一个Executable file以及另外一些 Shared object file 来一起处理，在Linux系统里面创建一个进程映像。

以上所提到的 link editor 以及 dynamic linker 是什么东西，你可以参考我们基本概念中的相关文章。对于什么是编译器，汇编器等你应该也已经知道，在这里只是使用他们而不再对他们进行详细介绍。为了下面的叙述方便，你可以下载test.tar.gz包，解压缩后使用"make"进行编译。编译完成后，会在目录中生成一系列的ELF对象文件，更多描述见里面的 README 文件。我们下面的论述都基于这些产生的对象文件。

make所产生的文件，包括 sub.o/sum.o/test.o/libsub.so/test 等等都是ELF对象文件。至于要知道它们都属于上面三类中的哪一种，我们可以使用 file 命令来查看：
