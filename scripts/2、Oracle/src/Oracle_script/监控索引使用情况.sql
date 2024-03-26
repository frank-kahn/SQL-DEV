---需要索引监视，以发现索引是否真的在使用。未使用的可以丢弃，以避免开销。
-- First enable monitoring usage for the indexes.

alter index siebel.S_ASSET_TEST monitoring usage;

--Below query to find the index usage:

select * from v$object_usage;