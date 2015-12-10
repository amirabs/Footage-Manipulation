%% Load UAV dataset

 

simpledir = '/cvgl/group/UAV_data/6-annotations-simple';
cd(simpledir);

a = dir;

for ki = 3:length(a);

    %cd(a(ki).name)
    
    cd(fullfile(simpledir,a(ki).name));
    
    vid = dir('video*');

    for did=1:length(vid);
        videodir = fullfile(simpledir,a(ki).name,vid(did).name);
        if ~exist(fullfile(videodir,'obsmat.mat'),'file')
            cd(videodir);

            load([ 'annotations.mat']);

            D(did).label = [a(ki).name '_' vid(did).name];

            D(did).H = eye(3);

            D(did).obstacles = [0 0];

            Obsmat = [];

            for k = 1:length(annotations) %#ok<*USENS>

                x = mean([annotations{k}.xbr annotations{k}.xtl]);

                y = mean([annotations{k}.ybr annotations{k}.ytl]);

                l = annotations{k}.label;

                if isequal(l,'Pedestrian')

                    l = 1;

                elseif isequal(l,'Biker')

                    l = 2;

                elseif isequal(l,'Cart')

                    l = 3;

                elseif isequal(l,'Skater')

                    l = 4;

                elseif isequal(l,'Car')

                    l = 5;

                elseif isequal(l,'Bus')

                    l = 6;

                end

                Obsmat = [Obsmat;annotations{k}.frame annotations{k}.id+1 x y l annotations{k}.generated annotations{k}.lost annotations{k}.occluded]; %#ok<*AGROW>      %(time, id, px, py)

            end

            

            [~,ord] = sort(Obsmat(:,2));

            Obsmat = Obsmat(ord,:);

            

            Obsmat(:,6) = [Obsmat(2:end,4)-Obsmat(1:end-1,4); mean(Obsmat(2:end,4)-Obsmat(1:end-1,4))];

            Obsmat(:,7) = [Obsmat(2:end,5)-Obsmat(1:end-1,5); mean(Obsmat(2:end,5)-Obsmat(1:end-1,5))];

            

            Obsmat(:,[5 6 7]) = Obsmat(:,[6 7 5]);

            

            [~,ord] = sort(Obsmat(:,1));

            Obsmat = Obsmat(ord,:);

            

            persons = unique(Obsmat(:,2));

            persons = [persons zeros(size(persons,1),3)];

            observations = [Obsmat ones(size(Obsmat,1),1)];

            save('obsmat.mat', 'Obsmat','persons', 'observations')

        end;

    end

end