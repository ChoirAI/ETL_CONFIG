# ETL_CONFIG
store the etl config for all customers

> for etl detail technical documents, please refer to this [link](https://d0qlhoqt8g.feishu.cn/wiki/D7lswJwUaizhScki6sZcKSKnnOb)

for each customer, we need to add new databases to support the ETL tasks by running the following script. 
```commandline
# remind the pg_vector extension need a superuser role.
./prepare_db_{customer}.sh BI_DB_NAME DW_DB_NAME HOST PORT BI_USER BI_PW DW_USER DW_PW
```
