require_modules(
	'ceremony/legion/helpers/model_helper',
	'ceremony/legion/helpers/controller_helper',
	-- requiring Models
	'ceremony/legion/models/legion_war',
	'ceremony/legion/models/legion_config',
	'ceremony/legion/models/legion_war_config',


	'ceremony/legion/controller/legion_war_controller',
	'ceremony/legion/controller/legion_controller',

	-- requiring Pages and Views
	'ceremony/legion/views/basic/legion_view',
	'ceremony/legion/views/basic/legion_page',
	'ceremony/legion/views/basic/legion_cell',
	'ceremony/legion/views/legion_join_page',
	'ceremony/legion/views/legion_join_cell',
	'ceremony/legion/views/legion_create_page',
	'ceremony/legion/views/legion_badge_panel',
	'ceremony/legion/views/legion_create_root_panel',
	'ceremony/legion/views/legion_mine_page',
	'ceremony/legion/views/legion_mine_cell',
	'ceremony/legion/views/legion_member_cell',
	'ceremony/legion/views/legion_member_page',
	'ceremony/legion/views/legion_shop_page',
	'ceremony/legion/views/legion_tech_cell',
	'ceremony/legion/views/legion_tech_upgrade_panel',
	'ceremony/legion/views/legion_tech_page',
	'ceremony/legion/views/legion_activity_cell',
	'ceremony/legion/views/legion_activity_page',
	'ceremony/legion/views/legion_rank_page',
	'ceremony/legion/views/legion_rank_cell',
	'ceremony/legion/views/legion_main_panel',
	'ceremony/legion/views/legion_donate_panel',
	'ceremony/legion/views/legion_tech_upgrade_panel',
	'ceremony/legion/views/legion_praying_panel',
	'ceremony/legion/views/legion_info_panel',
	'ceremony/legion/views/legion_seting_panel',
	'ceremony/legion/views/legion_tips_panel',
	'ceremony/legion/views/legion_help_panel',
	'ceremony/legion/views/legion_kill_role',

	'ceremony/legion/views/legion_war/legion_war_entrance_panel',
	'ceremony/legion/views/legion_war/legion_war_battle_panel',
	'ceremony/legion/views/legion_war/legion_war_city_panel',
	'ceremony/legion/views/legion_war/legion_war_city_cell',
	'ceremony/legion/views/legion_war/legion_war_round_result_panel',
	'ceremony/legion/views/legion_war/legion_war_round_result_cell',
	'ceremony/legion/views/legion_war/legion_war_tips_panel',
	'ceremony/legion/views/legion_war/legion_war_score_rank_panel',
	'ceremony/legion/views/legion_war/legion_war_result_panel',
	'ceremony/legion/views/legion_war/legion_war_info_panel',
	'ceremony/legion/views/legion_war/legion_war_help_panel',
	'ceremony/legion/views/legion_war/legion_war_timeout_panel'
)