extends Piece

class_name Piece_Bumper

func initiate_kickback(awayPos : Vector3):
	super(awayPos);
	set_cooldown_passive();
