%% To Do

%%
root = '/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/AVCnn_2017_RobLob/subjects';

cd(root);

spm_path = '/i2bm/local/spm12';
addpath(spm_path);
subjectsdir = root;
subj_header = '/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/Script_RobLob/Roblob_pipeline_controls/sub_list.txt' ;
[subjects] = textread(subj_header,'%s') ;

manip = 'Roblob'; %nom du dossier ou sont sauvegardé les sorties de RobLob.
skullstripfilter = 'skull_stripped*.nii' ;
grey_segmentation_filter = 'grey_matter_segmentation_*.nii' ; 
white_segmentation_filter = 'white_matter_segmentation*.nii';
grey_white_segmentation_filter = 'grey_white_segmentation*.nii';
% End of configuration section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create one job per subject

nsubj = length(subjects) ;

jobs = cell(nsubj,1);
inputs = cell(0, nsubj);
%%
for s = 1:nsubj
    subjdir = fullfile(subjectsdir, subjects{s} );
    
    skullstrip_dir = fullfile(subjdir,manip);
    skullstripped_files = dir(fullfile(skullstrip_dir, skullstripfilter)) ;
    if isempty(skullstripped_files)
        warning('No skull stripped file found for %s', ...
                        subjects{s})
        return
    elseif length(skullstripped_files) > 1
        warning('Several skullstripped files found for %s,%s will be used',...
                subjects{s},skullstripped_files(1).name)
        return
    end
    skullstrip_file = fullfile(skullstrip_dir,skullstripped_files(1).name);
    
    segmentations_dir =  fullfile( subjdir,manip);    
    grey_segmentation_files = dir(fullfile(segmentations_dir, grey_segmentation_filter)) ;
   
    if isempty(grey_segmentation_files)
        warning('No grey_segmentation file found for %s', ...
                        subjects{s})
        return
    elseif length(grey_segmentation_files) > 1
        grey_segmentation_file = fullfile(segmentations_dir,grey_segmentation_files(1).name);
        warning('Several grey_segmentation files found for %s', ...
                '%s will be used',...
                subjects{s},grey_segmentation_files(1).name)
        return
    else
        grey_segmentation_file = fullfile(segmentations_dir,grey_segmentation_files(1).name);
    end
    
        white_segmentation_files = dir(fullfile(segmentations_dir, white_segmentation_filter)) ;
   
    if isempty(white_segmentation_files)
        warning('No white segmentation file found for %s', ...
                        subjects{s})
        return
    elseif length(white_segmentation_files) > 1
        white_segmentation_file = fullfile(segmentations_dir,white_segmentation_files(1).name);
        warning('Several white segmentation files found for %s', ...
                '%s will be used',...
                subjects{s},white_segmentation_files(1).name)
        return
    else
        white_segmentation_file = fullfile(segmentations_dir,white_segmentation_files(1).name);
    end
    
    
        grey_white_segmentation_files = dir(fullfile(segmentations_dir,grey_white_segmentation_filter)) ;
   
    if isempty(grey_white_segmentation_files)
        warning('No grey_white_segmentation file found for %s', ...
                        subjects{s})
        return
    elseif length(grey_white_segmentation_files) > 1
        grey_segmentation_file = fullfile(segmentations_dir,grey_white_segmentation_files(1).name);
        warning('Several grey_white_segmentation files found for %s', ...
                '%s will be used',...
                subjects{s},grey_white_segmentation_files(1).name)
        return
    else
        grey_white_segmentation_file = fullfile(segmentations_dir,grey_white_segmentation_files(1).name);
    end
    

    clear matlabbatch
    
    %%%%%%%%%%%%%%%%%
    %%%    preprocess_job 
    job = 0;
    display 'Creating preprocessing job'

    % job 1 :  coregistration of anat to meanEPI
    job = job+1;    
    matlabbatch{job}.spm.spatial.coreg.estwrite.ref = {skullstrip_file};
    matlabbatch{job}.spm.spatial.coreg.estwrite.source = {grey_segmentation_file};
    matlabbatch{job}.spm.spatial.coreg.estwrite.other = {white_segmentation_file,grey_white_segmentation_file}';
    matlabbatch{job}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{job}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{job}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{job}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{job}.spm.spatial.coreg.estwrite.roptions.interp = 0;
    matlabbatch{job}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{job}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{job}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';


    
    %% write and save final batch
    batchdir = fullfile(root,'/spm_batch/roblob'); %directory to save batch
    mkdir(batchdir)
    batchname = [ subjects{s} '.mat' ];
    save(fullfile(batchdir,batchname),'matlabbatch')
    display(sprintf('batch saved at location %s',batchdir))
end
