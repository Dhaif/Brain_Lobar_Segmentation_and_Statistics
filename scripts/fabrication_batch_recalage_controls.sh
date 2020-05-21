#!/bin/bash
i=0
compteur=$(($nb_subjects - 1))
while [ $i -le $compteur ]; do

#dezip des fichiers d'interets pour SPM qui ne lit pas les .nii.gz mais juste les .nii
gunzip -k $subject_directory/${subject_list[$i]}/$save_directory_name/skull_stripped_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/grey_matter_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/white_matter_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/grey_white_segmentation_${subject_list[$i]}.nii.gz

i=$(($i+1))
done

#execution du script matlab qui va fabriquer les batchs individuels
matlab-R2016a -nojvm -nodisplay -nosplash -r "run('$batch_directory/recalage_Skull_stripped_anat_segmentation_controls.m'); exit();" -logfile $subject_directory/log_batch_recalage
