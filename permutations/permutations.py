import random


with  open('before.m') as file:
    before = file.readlines()
    #    for line in file:
    #        out_f.write(line)
with  open('permute.m') as file:
    permute = file.readlines()
    #    for line in file:
    #        out_f.write(line)
with  open('after.m') as file:
    after = file.readlines()
    #    for line in file:
    #        out_f.write(line)
    

for i in range(200):
    random.shuffle(permute)
    with open('versions/test'+str(i)+'.m', 'w') as out_f:
        for line in before:
            out_f.write(line)
        for line in permute:
            out_f.write(line)
        for line in after:
            out_f.write(line)
        out_f.write("save('results_" + str(i) + "', 'r_sum', 'E_A_sys', 'Q_E_sys', 'Q_G_sys') ")