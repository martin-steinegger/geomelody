<div class="songs view">
<h2><?php echo __('Song'); ?></h2>
	<dl>
		<dt><?php echo __('Id'); ?></dt>
		<dd>
			<?php echo h($song['Song']['id']); ?>
			&nbsp;
		</dd>
		<dt><?php echo __('SC Song Id'); ?></dt>
		<dd>
			<?php echo h($song['Song']['soundcloud_song_id']); ?>
			&nbsp;
		</dd>
		<dt><?php echo __('SC User Id'); ?></dt>
		<dd>
			<?php echo h($song['Song']['soundcloud_user_id']); ?>
			&nbsp;
		</dd>
		<dt><?php echo __('Comment'); ?></dt>
		<dd>
			<?php echo h($song['Song']['comment']); ?>
			&nbsp;
		</dd>
		<dt><?php echo __('Longitude'); ?></dt>
		<dd>
			<?php echo h($song['Song']['longitude']); ?>
			&nbsp;
		</dd>
		<dt><?php echo __('Latitude'); ?></dt>
		<dd>
			<?php echo h($song['Song']['latitude']); ?>
			&nbsp;
		</dd>
	</dl>
</div>

<div class="actions">
	<h3><?php echo __('Actions'); ?></h3>
	<ul>
		<li><?php echo $this->Html->link(__('Edit Song'), array('action' => 'edit', $song['Song']['id'])); ?> </li>
		<li><?php echo $this->Form->postLink(__('Delete Song'), array('action' => 'delete', $song['Song']['id']), null, __('Are you sure you want to delete # %s?', $song['Song']['id'])); ?> </li>
		<li><?php echo $this->Html->link(__('List Songs'), array('action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Song'), array('action' => 'add')); ?> </li>
		<li><?php echo $this->Html->link(__('List Tags'), array('controller' => 'tags', 'action' => 'index')); ?> </li>
		<li><?php echo $this->Html->link(__('New Tag'), array('controller' => 'tags', 'action' => 'add')); ?> </li>
	</ul>
</div>
<div class="related">
	<h3><?php echo __('Related Tags'); ?></h3>
	<?php if (!empty($song['Tag'])): ?>
	<table cellpadding = "0" cellspacing = "0">
	<tr>
		<th><?php echo __('Id'); ?></th>
		<th><?php echo __('Name'); ?></th>
		<th class="actions"><?php echo __('Actions'); ?></th>
	</tr>
	<?php
		$i = 0;
		foreach ($song['Tag'] as $tag): ?>
		<tr>
			<td><?php echo $tag['id']; ?></td>
			<td><?php echo $tag['name']; ?></td>
			<td class="actions">
				<?php echo $this->Html->link(__('View'), array('controller' => 'tags', 'action' => 'view', $tag['id'])); ?>
				<?php echo $this->Html->link(__('Edit'), array('controller' => 'tags', 'action' => 'edit', $tag['id'])); ?>
				<?php echo $this->Form->postLink(__('Delete'), array('controller' => 'tags', 'action' => 'delete', $tag['id']), null, __('Are you sure you want to delete # %s?', $tag['id'])); ?>
			</td>
		</tr>
	<?php endforeach; ?>
	</table>
<?php endif; ?>

	<div class="actions">
		<ul>
			<li><?php echo $this->Html->link(__('New Tag'), array('controller' => 'tags', 'action' => 'add')); ?> </li>
		</ul>
	</div>
</div>

<div class="related">
	 <div id="map-canvas" style="height:250px"></div>
</div>

<script>
var map;
function initialize() {
	var myLatLng = new google.maps.LatLng(<?php echo h($song['Song']['latitude']); ?>, <?php echo h($song['Song']['longitude']); ?>);

	var mapOptions = {
		zoom: 8,
		center: myLatLng,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};

	map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

	var beachMarker = new google.maps.Marker({
		position: myLatLng,
		map: map
	});
}

google.maps.event.addDomListener(window, 'load', initialize);
</script>