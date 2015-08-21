classdef plotTransient
    methods
        function obj = plotTransient()
        end
        function U(obj,myDir,myPlot,includePlot,name)
            %% ***************************************
            % Clear workspace and prescribe path
            % clear;clc;close all;
            p = mfilename('fullpath');
            [thisDir] = fileparts(p);
            chdir(thisDir); myDir.this = thisDir;
            % ***************************************

            name.field = 'Ufield';
            name.varx = 'u';name.vary = 'v';name.varz = 'w';
            myPlot.m = 2; myPlot.n = 2;

            %% Set working directory
            myDir.working = myDir.source;
            myDir.saveTo = true;
            myDir.saveExt = 'figs';
            myDir.working = myDir.source;

            %% TRANSIENT DATA
            name.saveFile = 'transient_data_U';
            myPlot.errorLog = 2;

            myPlot.subPlotNum = 1;
            name.file = ['transient_' name.varx(1)];
            name.title = name.varx;
            obj.transientSolution(myDir,name,myPlot);

            myPlot.subPlotNum = 2;
            name.file = ['transient_div' name.field(1)];
            name.title = ['L_2 error of \nabla \bullet ' name.field(1)];
            obj.transient(myDir,name,myPlot);

            myPlot.subPlotNum = 3;
            name.file = 'transient_ppe';
            name.title = 'L_2 error of PPE Residual';
            obj.transient(myDir,name,myPlot);

            myPlot.subPlotNum = 4;
            name.file = 'u_symmetry';
            name.title = 'Transient symmetry';
            obj.transient(myDir,name,myPlot);

        end
        function B(obj,myDir,myPlot,includePlot,name)
            %% ***************************************
            % Clear workspace and prescribe path
            % clear;clc;close all;
            p = mfilename('fullpath');
            [thisDir] = fileparts(p);
            chdir(thisDir); myDir.this = thisDir;
            % ***************************************

            name.field = 'Bfield';
            name.varx = 'Bx';name.vary = 'By';name.varz = 'Bz';
            myPlot.m = 2; myPlot.n = 2;

            %% Set working directory
            myDir.working = myDir.source;
            myDir.saveTo = true;
            myDir.working = myDir.source;

            %% TRANSIENT DATA
            name.saveFile = 'transient_data_B';
            myPlot.errorLog = 2;

            myPlot.subPlotNum = 1;
            name.file = ['transient_' name.varx];
            name.title = name.varx;
            obj.transientSolution(myDir,name,myPlot);

            myPlot.subPlotNum = 2;
            name.file = ['transient_div' name.field(1)];
            name.title = ['L_2 error of \nabla \bullet ' name.field(1)];
            obj.transient(myDir,name,myPlot);

        end
        function J(obj,myDir,myPlot,includePlot,name)
            %% ***************************************
            % Clear workspace and prescribe path
            % clear;clc;close all;
            p = mfilename('fullpath');
            [thisDir] = fileparts(p);
            chdir(thisDir); myDir.this = thisDir;
            % ***************************************

            name.field = 'Jfield';
            name.varx = 'jx';name.vary = 'jy';name.varz = 'jz';
            myPlot.m = 2; myPlot.n = 2;

            %% Set working directory
            myDir.working = myDir.source;
            myDir.saveTo = true;
            myDir.working = myDir.source;

            %% TRANSIENT DATA
            name.saveFile = 'transient_data_J';
            myPlot.errorLog = 2;

            myPlot.subPlotNum = 1;
            name.file = ['transient_' name.varx];
            name.title = name.varx;
            obj.transientSolution(myDir,name,myPlot);

            myPlot.subPlotNum = 2;
            name.file = ['transient_div' name.field(1)];
            name.title = ['L_2 error of \nabla \bullet ' name.field(1)];
            obj.transient(myDir,name,myPlot);

        end
        
        function transient(obj,myDir,name,myPlot)

            addpath([myDir.working name.field])

            data = importdata([name.file '.dat']);
            data = data.data;
            n = data(:,1);
            var = data(:,2);

            if isfield(myPlot,'subPlotNum')
                if myPlot.subPlotNum==1
                    figure('Position',myPlot.vector);
                end
                subplot(2,2,myPlot.subPlotNum)
            else
                figure('Position',myPlot.vector);
            end
            if myPlot.errorLog==1
                loglog(n,var)
            elseif myPlot.errorLog==2
                semilogy(n,var)
            else
                plot(n,var)
            end
            % plot(n,var)

            if strcmp(name.field,'Bfield')
                xlabel('n_{induction}')
            else
                xlabel('n_{mhd}')
            end
            ylabel(name.title)
            title(name.title)
            axis square

            saveMyPlot(myDir,name)

            rmpath([myDir.working name.field])

        end
        
        function transientSolution(obj,myDir,name,myPlot)

            addpath([myDir.working name.field])

            data = importdata([name.file '.dat']);
            data = data.data;
            % data = myImport(name,1);

            data = importdata([name.file '.dat']);
            data = data.data;
            n = data(:,1);
            var = data(:,2);
            name.file
            data2 = importdata([name.file '_info.dat']);
            h = data2.data(2,:);
            x = h(1); y = h(2); z = h(3);
            
            if isfield(myPlot,'subPlotNum')
                if myPlot.subPlotNum==1
                    figure('Position',myPlot.vector);
                end
                subplot(2,2,myPlot.subPlotNum)
            else
                figure('Position',myPlot.vector);
            end
            plot(n,var)
            
            T = [n(:) var(:)]; %#ok
            save([myDir.working name.field '\' 'transient_' name.varx(1) '_tecplot.dat'] ,'T','-ascii')

            if strcmp(name.field,'Bfield')
                xlabel('n_{induction}')
            else
                xlabel('n_{mhd}')
            end
            ylabel(name.title)
            title([name.title ' at x = ' num2str(x) ', y = ' num2str(y) ', z = ' num2str(z)])
            axis square

            temp = name;
            if isfield(name,'saveFile')
                name.file = ['transient_' name.saveFile];
            else
                name.file = ['transient_' name.file];
                saveMyPlot(myDir,name)
            end
            name = temp; clear temp

            rmpath([myDir.working name.field])

        end
        function transientSolutionOld(obj,myDir,name,myPlot)

            addpath([myDir.working name.field])

            data = importdata([name.file '.dat']);
            data = data.data;
            % data = myImport(name,1);

            x = data(1,1);
            y = data(1,2);
            z = data(1,3);
            n = data(:,4);
            var = data(:,5);

            if isfield(myPlot,'subPlotNum')
                if myPlot.subPlotNum==1
                    figure('Position',myPlot.vector);
                end
                subplot(2,2,myPlot.subPlotNum)
            else
                figure('Position',myPlot.vector);
            end
            plot(n,var)
            
            T = [n(:) var(:)]; %#ok
            save([myDir.working name.field '\' 'transient_' name.varx(1) '_tecplot.dat'] ,'T','-ascii')

            if strcmp(name.field,'Bfield')
                xlabel('n_{induction}')
            else
                xlabel('n_{mhd}')
            end
            ylabel(name.title)
            title([name.title ' at x = ' num2str(x) ', y = ' num2str(y) ', z = ' num2str(z)])
            axis square

            temp = name;
            if isfield(name,'saveFile')
                name.file = ['transient_' name.saveFile];
            else
                name.file = ['transient_' name.file];
                saveMyPlot(myDir,name)
            end
            name = temp; clear temp

            rmpath([myDir.working name.field])

        end
    end
end