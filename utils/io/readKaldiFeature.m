function [name feat] = readKaldiFeature(fileName)

endian = 'l';

FID = fopen('G:\Github\experiments\decode\data\unisound\20151010_cv10\forward.ark', 'r');
%FID = fopen(fileName, 'r');
name = {};
feat = {};
byte_cnt = 1;
while 1
    [tmp,byte_cnt] = readUttName(FID, byte_cnt);
    if length(tmp)==0 
        break;
    end
    name{end+1} = tmp;
    % fprintf('name{%d} = %s\n', length(name), name{end});
    header = readHeader(FID, byte_cnt, endian);
    data = fread(FID, header.nframe * header.dim, 'float32', 0, endian)';
    feat{end+1} = reshape(data, header.dim, header.nframe);
    if 0
        imagesc(feat{end});
        title(regexprep(name{end}, '_', '\\_'));
        colorbar;
        pause(4);
    end
end
fclose(FID);


%%
function [header,byte_cnt] = readHeader(FID,byte_cnt, endian)
header.format = [];
byte_cnt = skipGap(FID, byte_cnt);
while 1
    tmp = fread(FID, 1, 'char');
    byte_cnt = byte_cnt + 1;
    if tmp==' '
        break;
    else
        header.format(end+1) = tmp;
    end
end
header.format = char(header.format);
byte_cnt = skipGap(FID,byte_cnt);
header.nframe = fread(FID, 1, 'int32', 0, endian); byte_cnt = byte_cnt + 4;
byte_cnt = skipGap(FID,byte_cnt);
header.dim = fread(FID, 1, 'int32', 0, endian); byte_cnt = byte_cnt + 4;


function byte_cnt = skipGap(FID, byte_cnt)
while 1
    tmp = fread(FID, 1, 'int8');
    byte_cnt = byte_cnt + 1;
    if tmp==0 || tmp==4
        break;
    end
end

function [uttName,byte_cnt] = readUttName(FID,byte_cnt)
uttName = [];
while 1
    tmp = fread(FID, 1, 'char');
    if length(tmp) == 0 % read end of the file
        break;
    elseif tmp==' '
        break;
    else
        uttName(end+1) = tmp;
    end
    byte_cnt = byte_cnt + 1;
end
uttName = char(uttName);
