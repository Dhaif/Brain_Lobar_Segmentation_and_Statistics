#calcul des volumes "cleaned" par le process de C. Fisher.
subject_directory=/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/AVCnn_2017_RobLob/subjects
subjects_list=(anat1_el120132 anat1_rm120072 anat1_lm120147 anat1_ms110042 anat1_jb120109)
nb_subjects=${#subjects_list[@]}
atlas_lobaire_indiv_dir=atlas_lobaire_individuel_MNI_et_natif
resultats_volume_dir=resultats_volumes
save_directory_name=Roblob

i=0
compteur=$(($nb_subjects - 1))
while [ $i -le $compteur ]; do


mni_to_native_grey_matter_atlasLobaire=$subject_directory/${subjects_list[$i]}/$save_directory_name/$atlas_lobaire_indiv_dir/mni_to_native_grey_matter_atlasLobaire_${subjects_list[$i]}_cleaned.nii.gz
mni_to_native_white_matter_atlasLobaire=$subject_directory/${subjects_list[$i]}/$save_directory_name/$atlas_lobaire_indiv_dir/mni_to_native_white_matter_atlasLobaire_${subjects_list[$i]}_cleaned.nii.gz 



#Volumes des labels pour les matières grise et blanche dans l'espace natif.
AimsRoiFeatures -i $mni_to_native_white_matter_atlasLobaire -o $subject_directory/${subjects_list[$i]}/$save_directory_name/$resultats_volume_dir/mni_to_native_white_matter_atlasLobaire_features_${subjects_list[$i]}_cleaned.csv
AimsRoiFeatures -i $mni_to_native_grey_matter_atlasLobaire -o $subject_directory/${subjects_list[$i]}/$save_directory_name/$resultats_volume_dir/mni_to_native_grey_matter_atlasLobaire_features_${subjects_list[$i]}_cleaned.csv


i=$(($i+1))
done
