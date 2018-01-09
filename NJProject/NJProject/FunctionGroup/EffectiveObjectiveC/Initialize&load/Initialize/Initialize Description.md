LRQBaseClass 和 LRQSubClass 主要来测试 initialize.

1. LRQBaseClass 中 实现了 initialize 方法.
2. 在调用 LRQSubClass 的时候,有如下输出:

17:26:42 <LRQBaseClass.m> -> 15 :self = LRQBaseClass
17:26:42 <LRQBaseClass.m> -> 15 :self = LRQSubClass

结论: LRQSubClass 并没有实现 initialize, 但是系统也会调用.这点和 load 方法不一样, 不实现 load 方法,系统不会自动调用.
     所以在编写 initialize 方法的时候,一定要加上 if (self == [ClassName class]) { //code... } 这个判断.

---

LRQSubClass+Bury.m

主要是实现了一个方法交换的功能.



