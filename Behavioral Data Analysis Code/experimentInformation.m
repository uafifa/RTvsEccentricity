function [protocolNames, colors, linestyle, axes] = experimentInformation()
% get: protocolNames
% get: colors
% get: linestyles
% get x and y axes
% get markers
prompt = {'Enter x axis', 'Enter y axis'};
dlgtitle = 'Input';
dims = [2 35];
definput = {'Eccentricity (°)', 'Reaction Time (ms)'};
axes = inputdlg(prompt,dlgtitle,dims,definput);

prompt = {'Enter Number of Protocols:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'4'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
Answer = str2num(answer{1});
if strcmp(answer,'4')
    answer = questdlg({'Is your experiment Eccentricity vs. RT?' 'Covert/Overt B/BBB'})
    if strcmp(answer,'Yes')
        protocolNames = {'Covert SRT'; 'Overt SRT'; 'Covert 3 CRT'; 'Overt 3CRT'};
        answer = questdlg({'Are you satisfied with the default colors:'...
            'Covert SRT = Gray' 'Overt SRT = Red' 'Covert 3 CRT = Blue'...
            'Overt 3 CRT = yellow' });
        if strcmp(answer,'Yes')
            colors = {[0.5020 0.5020 0.5020];[0 0 0]; ...
                [0.0745    0.6235    1.0000]; [0 0 1]};
        elseif strcmp(answer, 'No')            
            strArray = strings(1,Answer);
            defInputStr = strings(1,Answer);
            for ii = 1:Answer
                strArray(ii) = strcat('Enter Name of Color for Protocol', {' '}, string(ii), ':');
                strArray2 = cellstr(strArray);
                defInputStr(ii)  = 'black';
                defInputStr2 = cellstr(defInputStr);
            end
            prompt = strArray2;
            dlgtitle = 'Choose from these colors: gray, red, blue, light blue,maroon, black, green';
            dims = [1 35];
            definput = defInputStr2;
            answer = inputdlg(prompt,dlgtitle,dims,defInputStr2);
            colors = answer;       
        end
        answer = questdlg({'Are you satisfied with the default linestyles:'...
            'Covert SRT = - (single dash)' 'Overt SRT = -- (double dash)'...
            'Covert 3 CRT = - (single dash)' 'Overt 3 CRT = -- (double dash)'});
        if strcmp(answer, 'Yes')
            linestyle = {'-'; '--'; '-'; '--'};
        elseif strcmp(answer, 'No')
            clear strArray;
            clear defInputStr;
            clear strArray2;
            clear defInputStr2;
            strArray = strings(1,Answer);
            defInputStr = strings(1,Answer);
            for ii = 1:Answer
                strArray(ii) = strcat('Enter Linestyle for Protocol', {' '}, string(ii), ':');
                strArray2 = cellstr(strArray);
                defInputStr(ii)  = '--';
                defInputStr2 = cellstr(defInputStr);
            end
            prompt = strArray2;
            dlgtitle = 'Choose from these linestyles: ''-'' or ''--'' (single/double dash)';
            dims = [1 35];
            definput = defInputStr2;
            answer = inputdlg(prompt,dlgtitle,dims,defInputStr2);
            linestyle = answer;    
        end
    elseif strcmp(answer,'No')
        prompt = {'Enter Name of Protocol 1:', 'Enter Name of Protocol 2:',...
            'Enter Name of Protocol 3:', 'Enter Name of Protcol 4'};
        dlgtitle = 'Input';
        dims = [1 35];
        definput = {'Protocol 1', 'Protocol 2', 'Protocol 3', 'Protocol 4'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);
        protocolNames = answer;
        
        strArray = strings(1,Answer);
        defInputStr = strings(1,Answer);
        for ii = 1:Answer
            strArray(ii) = strcat('Enter Name of Color for Protocol', {' '}, string(ii), ':');
            strArray2 = cellstr(strArray);
            defInputStr(ii)  = 'black';
            defInputStr2 = cellstr(defInputStr);
        end
        prompt = strArray2;
        dlgtitle = 'Choose from these colors: gray, red, blue, light blue,maroon, black, green';
        dims = [1 35];
        definput = defInputStr2;
        answer = inputdlg(prompt,dlgtitle,dims,defInputStr2);
        colors = answer;
    end
        
    
    
else
    answer = str2num(answer{1});
    Answer = answer;
    strArray = strings(1,answer);
    defInputStr = strings(1,answer);
    for ii = 1:answer
        strArray(ii) = strcat('Enter Name of Protocol', {' '}, string(ii), ':');
         strArray2 = cellstr(strArray);
        defInputStr(ii)  = strcat('Protocol' , {' '}, string(ii));
        defInputStr2 = cellstr(defInputStr);
    end
    prompt = strArray2;
    dlgtitle = 'Input';
    dims = [1 35];
    definput = defInputStr2;
    answer = inputdlg(prompt,dlgtitle,dims,defInputStr2);
    protocolNames = answer;
    clear strArray;
    clear defInputStr;
    clear strArray2;
    clear defInputStr2;
    strArray = strings(1,Answer);
    defInputStr = strings(1,Answer);
    for ii = 1:Answer
        strArray(ii) = strcat('Enter Name of Color for Protocol', {' '}, string(ii), ':');
        strArray2 = cellstr(strArray);
        defInputStr(ii)  = 'black';
        defInputStr2 = cellstr(defInputStr);
    end
    prompt = strArray2;
    dlgtitle = 'Choose from these colors: gray, red, blue, light blue,maroon, black, green';
    dims = [1 35];
    definput = defInputStr2;
    answer = inputdlg(prompt,dlgtitle,dims,defInputStr2);
    colors = answer;
    
    clear strArray;
    clear defInputStr;
    clear strArray2;
    clear defInputStr2;
    strArray = strings(1,Answer);
    defInputStr = strings(1,Answer);
    for ii = 1:Answer
        strArray(ii) = strcat('Enter Linestyle for Protocol', {' '}, string(ii), ':');
        strArray2 = cellstr(strArray);
        defInputStr(ii)  = '--';
        defInputStr2 = cellstr(defInputStr);
    end
    prompt = strArray2;
    dlgtitle = 'Choose from these linestyles: ''-'' or ''--'' (single/double dash)';
    dims = [1 35];
    definput = defInputStr2;
    answer = inputdlg(prompt,dlgtitle,dims,defInputStr2);
    linestyle = answer;
end