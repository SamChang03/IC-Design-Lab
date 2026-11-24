1. The test is similar to the part2. The only different way is to generate all combination of Mode instead of using the Mode array.

2. How I find the 256 combination?

(1) From the observation, we can devide all the value into {4'hx,4'hy}. Then, if x=y I call it symmetic basis. And, we have 16 symmetric basis here. Fortunately, we only need to find 8 of them since 8'h00 = ~(8'hff),8'h11 = ~(8'hee) and so on. Luckly, on the table 1 provideed by TA include almost combinations of that.
Fun fact: All the symmetic basis are the combination of only S and D since S and D are also symmetric basis.

(2) After finding all the symmetiric basis, we can add P to this basis. If we let ~P = 0000_1111 & the symmertic basis, we can get the all combination of 4 bits 4'hy mentioned in (1). In the same way, we let P = 1111_0000 & the symmertic basis, we can get the all combination of 4 bits 4'hx mentioned in (1).

(3) Accoriding to the above, we can generate all the combination of 4'hx and 4'hy. This is the way I find the all combination of the ROP3 Modes.

