-- 给用户授权所有数据字典的查询权限
grant select any dictionary to test_user;

-- 数据泵需要使用的权限
grant datapump_exp_full_database to test01;

-- 获取某个用户的全部权限：系统权限、对象权限
