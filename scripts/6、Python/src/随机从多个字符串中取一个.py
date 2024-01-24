#从三个字符串中随机选一个
import random

string1 = "zhangsan"
string2 = "lisi"
string3 = "wangwu"

strings = [string1,string2,string3]
selected_string = random.choice(strings)
print(selected_string)





# 循环100次，并统计次数
import random

str_list = ["zhangsan","lisi","wangwu"]
count_dict = {s: 0 for s in str_list}
for i in range(100):
    s = random.choice(str_list)
    count_dict[s] += 1
print(count_dict)