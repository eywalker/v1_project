%{
# 
bin_config_id               : varchar(128)                  # id
---
bin_width                   : decimal(3,2)                  # 
bin_counts                  : int                           # number of bins
clip_outside                : tinyint                       # whether to clip outside
%}


classdef BinConfig < dj.Lookup
end