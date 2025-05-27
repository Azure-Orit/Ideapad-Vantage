using Gtk;

class MyWindow : ApplicationWindow {
	private Label bat_threshold;
	private Label usbcharge;
	private Label cam;
	private Label fn;
	private Label fan;
	private Label charge_cycles;
	private Label bat_lvl;
	private Label bat_status;
	private Switch switcher_bat;
	private Switch switcher_usb;
	private Switch switcher_cam;
	private Switch switcher_fn;
	private Label bat_health;
	private Label charge_cycles_value;
	private ProgressBar lvl_value;
	private Label status_value;
	private ProgressBar health_value;
    internal MyWindow (MyApplication app) {
        Object (application: app, title: "Ideapad Vantage");
        this.border_width = 20;
        bat_threshold = new Label ("Battery Threshold Status");
		bat_threshold.set_xalign (0);
		usbcharge = new Label ("Charge USB while powered off");
		usbcharge.set_xalign (0);
		cam = new Label ("Turn on Camera Module");
		cam.set_xalign(0);
		fn = new Label ("Turn on Fn Lock");
		fn.set_xalign (0);
		fan = new Label ("Fan Mode");
		fn.set_xalign (0);
		charge_cycles = new Label ("Charge Cyles");
		charge_cycles.set_xalign (0);
		bat_lvl = new Label ("Battery State of Charge");
		bat_status = new Label ("Current State");
		bat_status.set_xalign (0);
		bat_health = new Label ("Battery Health");
		lvl_value = new ProgressBar ();
		charge_cycles_value = new Label ("");
		charge_cycles_value.set_halign(Gtk.Align.END);
		status_value = new Label ("");
		status_value.set_halign(Gtk.Align.END);
		health_value = new ProgressBar ();
        switcher_bat = new Switch ();
		switcher_bat.set_halign(Gtk.Align.END);		
        switcher_usb = new Switch ();
		switcher_usb.set_halign(Gtk.Align.END);
		switcher_cam = new Switch ();
		switcher_cam.set_halign(Gtk.Align.END);
		switcher_fn = new Switch ();
		switcher_fn.set_halign(Gtk.Align.END);


        File conservation_mode = File.new_for_path ("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
		FileInputStream @fis0 = conservation_mode.read ();
		DataInputStream dis0 = new DataInputStream (@fis0);        
		string line;
		while ((line = dis0.read_line ()) != null) {
			if (int.parse (line) == 1){
				switcher_bat.set_active (true);
            	}
		}
		File usb_mode = File.new_for_path ("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/usb_charging");
		FileInputStream @fis_usb = usb_mode.read ();
		DataInputStream dis_usb = new DataInputStream (@fis_usb);        
		string line_usb;
		while ((line_usb = dis_usb.read_line ()) != null) {
			if (int.parse (line_usb) == 1){
				switcher_usb.set_active (true);
            	}
		}
        File fn_mode = File.new_for_path ("/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fn_lock");
		FileInputStream @fis_fn = fn_mode.read ();
		DataInputStream dis_fn = new DataInputStream (@fis_fn);        
		string line_fn;
		while ((line_fn = dis_fn.read_line ()) != null) {
			if (int.parse (line_fn) == 1){
				switcher_fn.set_active (true);
            	}
		}
		Timeout.add(50, () => {
			File cycle_count = File.new_for_path ("/sys/class/power_supply/BAT0/cycle_count");
			FileInputStream @fis1 = cycle_count.read ();
			DataInputStream dis1 = new DataInputStream (@fis1); 
			string string_cycles = dis1.read_line ();
			charge_cycles_value.set_label (string_cycles);
			return true;
		});
		Timeout.add(50, () => {
			File capacity = File.new_for_path ("/sys/class/power_supply/BAT0/capacity");
			FileInputStream @fis2 = capacity.read ();
			DataInputStream dis2 = new DataInputStream (@fis2); 
			string string_capacity = dis2.read_line ();
			double capacity_double = double.parse (string_capacity);
			double energy = capacity_double/100;
			lvl_value.set_fraction (energy);
			lvl_value.set_show_text (true);
			return true;
		});
		Timeout.add(50, () => {
			File status = File.new_for_path ("/sys/class/power_supply/BAT0/status");
			FileInputStream @fis3 = status.read ();
			DataInputStream dis3 = new DataInputStream (@fis3); 
			string string_status = dis3.read_line ();
			status_value.set_label (string_status);
			return true;
		});
		Timeout.add(50, () => {
			File energy_full = File.new_for_path ("/sys/class/power_supply/BAT0/energy_full");
			FileInputStream @fis4 = energy_full.read ();
			DataInputStream dis4 = new DataInputStream (@fis4); 
			string string_energy_full = dis4.read_line ();
			float double_energy_full = float.parse (string_energy_full);
			File energy_full_design= File.new_for_path ("/sys/class/power_supply/BAT0/energy_full_design");
			FileInputStream @fis5 = energy_full_design.read ();
			DataInputStream dis5 = new DataInputStream (@fis5); 
			string string_energy_full_design = dis5.read_line ();
			float double_energy_full_design = float.parse (string_energy_full_design);
			float 100_times = double_energy_full*100;
			float x = 100_times/double_energy_full_design;
			float x_rounded = Math.roundf(x * 100) / 100;
			float x_100 = x_rounded/100;
			health_value.set_fraction (x_100);
			health_value.set_show_text (true);
			return true;
		});
		

        switcher_bat.notify["active"].connect (switcher_bat_cb);
		switcher_usb.notify["active"].connect (switcher_usb_cb);
		switcher_fn.notify["active"].connect (switcher_fn_cb);
        var grid = new Grid ();
		
        grid.set_column_spacing (30);
		grid.set_row_spacing (10);
		grid.attach (bat_lvl, 0, 1, 3, 1);
		grid.attach (lvl_value, 0, 2, 3, 1);
		grid.attach (bat_health, 0, 3, 3, 1);
		grid.attach (health_value, 0, 4, 3, 1);
		grid.attach (bat_status, 0, 5, 1, 1);
		grid.attach (status_value, 1, 5, 2, 1);
		grid.attach (charge_cycles, 0, 6, 1, 1);
		grid.attach (charge_cycles_value, 1, 6, 2, 1);
        	grid.attach (bat_threshold, 0, 7, 1, 1);
        	grid.attach (switcher_bat, 2, 7, 1, 1);
		grid.attach (usbcharge, 0, 8, 1, 1);
		grid.attach (switcher_usb, 2, 8, 1, 1);
		grid.attach (fn, 0, 9, 1, 1);
		grid.attach (switcher_fn, 2, 9, 1, 1);

        this.add (grid);
        
}

void switcher_bat_cb (Object switcher_bat, ParamSpec pspec) {
	if ((switcher_bat as Switch).get_active())
        	Posix.system("echo 1 | pkexec tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
        else
        	Posix.system("echo 0 | pkexec tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode");
	}


void switcher_usb_cb (Object switcher_usb, ParamSpec pspec) {
	if ((switcher_usb as Switch).get_active())
        	Posix.system("echo 1 | pkexec tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/usb_charging");
        else
        	Posix.system("echo 0 | pkexec tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/usb_charging");
	}

void switcher_fn_cb (Object switcher_fn, ParamSpec pspec) {
	if ((switcher_fn as Switch).get_active())
        	Posix.system("echo 1 | pkexec tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fn_lock");
        else
        	Posix.system("echo 0 | pkexec tee /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/fn_lock");
	}
}

class MyApplication : Gtk.Application {
	protected override void activate () {
        	var window = new MyWindow (this);
        	window.icon = new Gdk.Pixbuf.from_file("/usr/local/share/ideapadvantage/icon.svg");
			window.set_default_size (200, 80);
        	window.show_all (); //show all the things
        	window.resizable = false;
    	}
    	internal MyApplication () {
        	Object (application_id: "com.github.Azure-Orit.Ideapad-Vantage");
    	}
}


int main (string[] args) {
	MyApplication app = new MyApplication();
   	return app.run (args);
}

