<?php
App::uses('AppModel', 'Model');
/**
 * Song Model
 *
 * @property Tag $Tag
 */
class Song extends AppModel {

/**
 * Display field
 *
 * @var string
 */
	public $displayField = 'soundcloud_song_id';


	//The Associations below have been created with all possible keys, those that are not needed can be removed

/**
 * hasAndBelongsToMany associations
 *
 * @var array
 */
	public $hasAndBelongsToMany = array(
		'Tag' => array(
			'className' => 'Tag',
			'joinTable' => 'songs_tags',
			'foreignKey' => 'song_id',
			'associationForeignKey' => 'tag_id',
			'unique' => 'keepExisting',
			'conditions' => '',
			'fields' => '',
			'order' => '',
			'limit' => '',
			'offset' => '',
			'finderQuery' => '',
			'deleteQuery' => '',
			'insertQuery' => ''
		)
	);

	public $virtualFields = array(
    	'longitude' => 'ST_X(geom)',
    	'latitude' => 'ST_Y(geom)'
	);

	public $validate = array(
        'longitude' => 'numeric',
        'latitude' => 'numeric'
    );

	public function beforeSave($options = array()) {
    if (!empty($this->data['Song']['longitude']) && !empty($this->data['Song']['latitude'])) {
    	$postGisPoint = sprintf('ST_SetSRID(ST_MakePoint(%s, %s), 4326)', $this->data['Song']['longitude'], $this->data['Song']['latitude']);
        $this->data['Song']['geom'] = $this->getDataSource()->expression($postGisPoint);

        unset($this->data['Song']['longitude']);
        unset($this->data['Song']['latitude']);

        return true;
    }
    return false;
}

}
