#!/bin/bash
i=0
compteur=$(($nb_subjects - 1))
while [ $i -le $compteur ]; do

#DEBUT ETAPE 2 PARTIE 2#################
#execution du script matlab qui va fabriquer les batchs individuels
#matlab-R2016a -nojvm -nodisplay -nosplash -r "run('$batch_directory/recalage_Skull_stripped_anat_segmentation_controls.m'); exit();" -logfile $subject_directory/log_batch_recalage

#lancement du batch de recalage du sujet
subject_batch=$batch_instruction_directory/${subject_list[$i]}.mat
spm12 run $subject_batch
PID=$!
wait $PID

#on efface les fichiers .nii dezipé precedemment qui ne servent plus
rm $subject_directory/${subject_list[$i]}/$save_directory_name/skull_stripped_${subject_list[$i]}.nii $subject_directory/${subject_list[$i]}/$save_directory_name/grey_matter_segmentation_${subject_list[$i]}.nii $subject_directory/${subject_list[$i]}/$save_directory_name/white_matter_segmentation_${subject_list[$i]}.nii $subject_directory/${subject_list[$i]}/$save_directory_name/grey_white_segmentation_${subject_list[$i]}.nii

#on zip les fichiers recalé, qui seront ensuite utilisé dans la fin du pipeline
gzip $subject_directory/${subject_list[$i]}/$save_directory_name/rgrey_matter_segmentation_${subject_list[$i]}.nii $subject_directory/${subject_list[$i]}/$save_directory_name/rwhite_matter_segmentation_${subject_list[$i]}.nii $subject_directory/${subject_list[$i]}/$save_directory_name/rgrey_white_segmentation_${subject_list[$i]}.nii


#on remplace bien les variable de grey et white matter par les fichiers recalés
white_matter_segmentation=$subject_directory/${subject_list[$i]}/$save_directory_name/rwhite_matter_segmentation_${subject_list[$i]}.nii.gz
grey_matter_segmentation=$subject_directory/${subject_list[$i]}/$save_directory_name/rgrey_matter_segmentation_${subject_list[$i]}.nii.gz




#Aplication du warp sur Grey et White segmentation
w_mni_subject_T1=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_${subject_list[$i]}.nii.gz

fsl5.0-applywarp -i $white_matter_segmentation -o $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_segmentation_${subject_list[$i]}.nii.gz -r $atlas_reference_normalisation -w $subject_directory/${subject_list[$i]}/$save_directory_name/nativeToMNI_deformation_field_${subject_list[$i]}.nii.gz --interp=nn

w_mni_white_segmentation=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_segmentation_${subject_list[$i]}.nii.gz

fsl5.0-applywarp -i $grey_matter_segmentation -o $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_segmentation_${subject_list[$i]}.nii.gz -r $atlas_reference_normalisation -w $subject_directory/${subject_list[$i]}/$save_directory_name/nativeToMNI_deformation_field_${subject_list[$i]}.nii.gz --interp=nn

w_mni_grey_segmentation=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_segmentation_${subject_list[$i]}.nii.gz


#Fusion de l'atlas lobaire dans l'espace normée et des segmentation de matiere blanche et grise dans l'espace normée
#source activate Python2_env

cartoLinearComb.py -o $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_matter_atlasLobaire_${subject_list[$i]}.nii.gz -f I1*I2 -i $w_mni_white_segmentation $atlas_lobaire 
cartoLinearComb.py -o $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_matter_atlasLobaire_${subject_list[$i]}.nii.gz -f I1*I2 -i $w_mni_grey_segmentation $atlas_lobaire 

#source deactivate Python2_env
w_mni_white_matter_atlasLobaire=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_matter_atlasLobaire_${subject_list[$i]}.nii.gz
w_mni_grey_matter_atlasLobaire=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_matter_atlasLobaire_${subject_list[$i]}.nii.gz


#Volumes des labels pour les matières grise et blanche dans l'espace du MNI.
AimsRoiFeatures -i $w_mni_white_matter_atlasLobaire -o $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_matter_atlasLobaire_features_${subject_list[$i]}.csv
AimsRoiFeatures -i $w_mni_grey_matter_atlasLobaire -o $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_matter_atlasLobaire_features_${subject_list[$i]}.csv


#Inversion des des whites et grey matter lobaire:
fsl5.0-applywarp -i $w_mni_grey_matter_atlasLobaire -o $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_grey_matter_atlasLobaire_${subject_list[$i]}.nii.gz -r $grey_matter_segmentation -w $subject_directory/${subject_list[$i]}/$save_directory_name/MNIToNative_deformation_field_${subject_list[$i]}.nii.gz --interp=nn

fsl5.0-applywarp -i $w_mni_white_matter_atlasLobaire -o $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_white_matter_atlasLobaire_${subject_list[$i]}.nii.gz -r $white_matter_segmentation -w $subject_directory/${subject_list[$i]}/$save_directory_name/MNIToNative_deformation_field_${subject_list[$i]}.nii.gz --interp=nn


mni_to_native_grey_matter_atlasLobaire=$subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_grey_matter_atlasLobaire_${subject_list[$i]}.nii.gz
mni_to_native_white_matter_atlasLobaire=$subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_white_matter_atlasLobaire_${subject_list[$i]}.nii.gz 



#Volumes des labels pour les matières grise et blanche dans l'espace natif.
AimsRoiFeatures -i $mni_to_native_white_matter_atlasLobaire -o $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_white_matter_atlasLobaire_features_${subject_list[$i]}.csv
AimsRoiFeatures -i $mni_to_native_grey_matter_atlasLobaire -o $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_grey_matter_atlasLobaire_features_${subject_list[$i]}.csv


i=$(($i+1))
done
