#!/bin/bash
i=0
compteur=$(($nb_subjects - 1))
while [ $i -le $compteur ]; do

mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/segmentations_espace_natif
segmentations_espace_natif=$subject_directory/${subject_list[$i]}/$save_directory_name/segmentations_espace_natif


#deplacement des segmentations dans l'espace natif
mv  $subject_directory/${subject_list[$i]}/$save_directory_name/grey_matter_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/grey_white_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/Lgrey_white_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/Rgrey_white_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/nuclei_posterior_brain_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/rgrey_matter_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/rgrey_white_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/rwhite_matter_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/voronoi_${subject_list[$i]}_4parts.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/white_matter_segmentation_${subject_list[$i]}.nii.gz $segmentations_espace_natif

#deplacement des segmentations dans l'espace du MNI
mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/segmentations_espace_MNI
segmentations_espace_MNI=$subject_directory/${subject_list[$i]}/$save_directory_name/segmentations_espace_MNI

mv $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_segmentation_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_segmentation_${subject_list[$i]}.nii.gz $segmentations_espace_MNI

#deplacement des fichiers anatomique T1 normée et inversé avec le champs de deformation
mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/anatT1_MNI_et_inverse
anatT1_MNI_et_inverse=$subject_directory/${subject_list[$i]}/$save_directory_name/anatT1_MNI_et_inverse

mv $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_${subject_list[$i]}.nii.gz $anatT1_MNI_et_inverse

#deplacement des atlas individuels individuels lobaire dans l'espace du MNI et natif
mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/atlas_lobaire_individuel_MNI_et_natif
atlas_lobaire_individuel_MNI_et_natif=$subject_directory/${subject_list[$i]}/$save_directory_name/atlas_lobaire_individuel_MNI_et_natif


mv $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_matter_atlasLobaire_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_matter_atlasLobaire_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_grey_matter_atlasLobaire_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_white_matter_atlasLobaire_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/inversion_fnirt_atlas_lobaire_${subject_list[$i]}.nii.gz $atlas_lobaire_individuel_MNI_et_natif

#deplacement des champs de deformation,jacobien, matrice de recalage affine
mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/champs_de_deformation
champs_de_deformation=$subject_directory/${subject_list[$i]}/$save_directory_name/champs_de_deformation

mv $subject_directory/${subject_list[$i]}/$save_directory_name/MNIToNative_deformation_field_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/nativeToMNI_deformation_field_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/affine_matrix_${subject_list[$i]}.mat $subject_directory/${subject_list[$i]}/$save_directory_name/inverse_affine_matrix_${subject_list[$i]}.mat $subject_directory/${subject_list[$i]}/$save_directory_name/jacobian_field_${subject_list[$i]}.nii.gz $champs_de_deformation

#deplacement de fichier intermediaire qui n'ont pas d'interet
mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/fichier_intermediaire
fichier_intermediaire=$subject_directory/${subject_list[$i]}/$save_directory_name/fichier_intermediaire

mv $subject_directory/${subject_list[$i]}/$save_directory_name/scaled_hemisphere_Grey_White_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/scaled_Lgrey_white_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/scaled_Rgrey_white_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/skull_stripped_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name/affine_registred_${subject_list[$i]}.nii.gz $fichier_intermediaire

#deplacement des resultats de volumes csv, xlsx.
mkdir $subject_directory/${subject_list[$i]}/$save_directory_name/resultats_volumes
resultats_volumes=$subject_directory/${subject_list[$i]}/$save_directory_name/resultats_volumes

mv $subject_directory/${subject_list[$i]}/$save_directory_name/${subject_list[$i]}_volume_lobaire_total_espace_natif.csv $subject_directory/${subject_list[$i]}/$save_directory_name/${subject_list[$i]}_volume_lobaire_total_espace_natif.xlsx $subject_directory/${subject_list[$i]}/$save_directory_name/grey_matter_${subject_list[$i]}_volume_natif.csv $subject_directory/${subject_list[$i]}/$save_directory_name/white_matter_${subject_list[$i]}_volume_natif.csv $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_grey_matter_atlasLobaire_features_${subject_list[$i]}.csv $subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_white_matter_atlasLobaire_features_${subject_list[$i]}.csv $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_grey_matter_atlasLobaire_features_${subject_list[$i]}.csv $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_white_matter_atlasLobaire_features_${subject_list[$i]}.csv $resultats_volumes


#on efface les .minf qui ne servent a rien
rm $subject_directory/${subject_list[$i]}/$save_directory_name/*.minf


i=$((i+1))
done
