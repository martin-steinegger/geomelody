<div class="songs form">
<?php echo $this->Form->create('Song'); ?>
	<fieldset>
		<legend><?php echo __('Admin Edit Song'); ?></legend>
	<?php
		echo $this->Form->input('id');
		echo $this->Form->input('soundcloud_song_id', array('type' => 'text'));
		echo $this->Form->input('soundcloud_user_id', array('type' => 'text'));
		echo $this->Form->input('comment');
		echo $this->Form->input('longitude', array('type' => 'text'));
		echo $this->Form->input('latitude', array('type' => 'text'));
?>
	 <div id="map-canvas" style="height:250px"></div>

<script>
var map;
function initialize() {
	var latitude = $('#SongLatitude').val();
	var longitude = $('#SongLongitude').val();
	var myLatLng = new google.maps.LatLng(latitude, longitude);

	var mapOptions = {
		zoom: 8,
		center: myLatLng,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};

	map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

	positionMarker = new google.maps.Marker({
		position: myLatLng,
		map: map
	});

	google.maps.event.addListener(map, 'click', function(event) {
    	positionMarker.setPosition(event.latLng);
    	$('#SongLatitude').val(event.latLng.lat());
    	$('#SongLongitude').val(event.latLng.lng());
  	});
}

google.maps.event.addDomListener(window, 'load', initialize);
</script>

<?php
		echo $this->Form->input('Tag');
	?>
	</fieldset>
<?php echo $this->Form->end(__('Submit')); ?>
</div>
<div class="actions">
	<h3><?php echo __('Actions'); ?></h3>
	<ul>

		<li><?php echo $this->Form->postLink(__('Delete'), array('action' => 'delete', $this->Form->value('Song.id')), null, __('Are you sure you want to delete # %s?', $this->Form->value('Song.id'))); ?></li>
		<li><?php echo $this->Html->link(__('List Songs'), array('action' => 'index')); ?></li>
		<li><?php echo $this->Html->link(__('List Tags'), array('controller' => 'tags', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Tag'), array('controller' => 'tags', 'action' => 'add')); ?> </li>
	</ul>
</div>
