function modules = readKaldiNetwork(file_name)
file_name = 'G:\corpus\final.nnet.txt';
FID = fopen(file_name, 'r');

modules = {};
while ~feof(FID)
    line = fgetl(FID);
    if ~isempty(strfind(line, '<!') ),  continue; end % end of component
    if ~isempty(regexp(line,'</?Nnet>', 'once')), continue; end; %for nnet start of end tag;
    if line(1) == '<',
        fprintf('Reading %s - %s\n', line, datestr(now));
        tokens=regexp(line, '<(\w+)>\s*(\d+)\s*(\d+)', 'tokens');
        modules{end+1}.name=tokens{1}{1};
        modules{end}.in=str2num(tokens{1}{3});
        modules{end}.out=str2num(tokens{1}{2});

        line = fgetl(FID);
        tokens=regexp(line, '<(\w+)>\s*(\d+)', 'tokens');
        for i=1:length(tokens)
            eval ([ 'modules{end}.' tokens{i}{1} '=' tokens{i}{2}  ';']);
        end
        
        switch modules{end}.name
            case {'affinetransform', 'AffineTransform'}
                modules{end}.transform = readmat(FID, modules{end}.in);
                modules{end}.bias = readmat(FID, modules{end}.out);
                
            case {'lineartransform', 'LinearTransform'}
                modules{end}.transform = readmat(FID, modules{end}.in);
                
            case {'sigmoid', 'softmax', 'Sigmoid', 'Softmax'}
                % Do nothing
            case {'Splice', 'splice', 'AddShift', 'addshift', 'rescale', 'Rescale'}
                modules{end}.transform = readmat(FID, modules{end}.out);

            otherwise
                fprintf('Error: unknown processing step: %s~\n', modules{end}.name);
                break;
        end
    else
        break;
    end
end
fclose(FID);


function str = read_vec(fid)
str=[];
while ~feof(fid)
    txt=fgetl(fid);
    nstart = strfind(txt, '[');
    if isempty(nstart),
       continue
    end
    %find the start
    str=txt(nstart:end);
    nend = strfind(str, ']');
    if ~isempty(nend)
         str = str(1:nend);
        return 
    end
    break;
end

while ~feof(fid)
    txt=fgetl(fid);
    nend = strfind(txt, ']');
    if isempty(nend)
        str= [str  txt];
        continue;
    end
    %find the end
    str= [str txt(1:nend)];
    break 
end
   

function m = readmat(fid, ncol)
m = eval( read_vec(fid));
m = reshape(m, ncol,[]);