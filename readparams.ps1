f = open(r'\Users\john-mchugh\Documents\Analog Devices\SigmaStudio 4.5\RPI\params\params.params')
data = f.readlines()
elems = []
pos = 0
midi_pos = 0
type_pos = 1
id_pos = 2
min_pos = 3
max_pos = 4
format_pos = 5
midi = "midi"
osc = "osc"
knob = "knob"
pad = "pad"
midi_osc = "midi_osc"
midi_knob = "midi_knob"
midi_pad = "midi_pad"
midi_adsr = "midi_adsr"
midi_vel = "midi_vel"
adsr = "adsr"
vel = "vel"
adsr_addr = "aAddr"
vel_addr = "vAddr"

cell_name = "Cell Name"
param_name = "Parameter Name"
param_add = "Parameter Address"
param_val = "Parameter Value"
inc = "inc"
cur = -1
ignoreblock = True
oscblock = False

class melem:
	def __init__(self):
		self.mtype = ""
		self.vaddr = ""
		self.aaddr = ""
		self.id = ""
		self.min = ""
		self.max = ""
		self.format = "824"
		self.writeXML = True

for line in data:
	v = line.split("=")
	if len(v) > 1:
		#print(v[1], end='')
		if v[0].find(cell_name) > -1:
			if v[1].find(midi) > -1:
				ignoreblock = False
				oscblock = False
				e = melem()
				elems.append(e)
				cur = len(elems) - 1
				desc = v[1].split("_")
				if len(desc) > 1:
					for d in desc:
						if d.find(midi) > -1:
							pos = type_pos
						elif pos == type_pos:
							if d.find(osc) > -1:
								e.mtype = midi_osc
								pos = id_pos
							elif d.find(knob) > -1:
								e.mtype = midi_knob
								pos = id_pos
							elif d.find(pad) > -1:
								e.mtype = midi_pad
								pos = id_pos
							elif d.find(adsr) > -1:
								e.mtype = midi_adsr
								e.writeXML = False
								pos = id_pos
							elif d.find(vel) > -1:
								e.mtype = midi_vel
								e.writeXML = False
								pos = id_pos
						elif pos == id_pos:
							e.id = d.strip()
							pos = min_pos
						elif pos == min_pos:
							e.min = d.strip()
							pos = max_pos
						elif pos == max_pos:
							e.max = d.strip()
							pos = format_pos
						elif pos == format_pos:
							e.format = d.strip()
			else:
				ignoreblock = True
		elif not ignoreblock and cur > -1 and v[0].find(param_name) > -1:
			if elems[cur].mtype == midi_osc:
				if v[1].find(inc) == -1:
					elems.pop(cur)
					ignoreblock = True
		elif not ignoreblock and cur > -1 and v[0].find(param_add) > -1:
			elems[cur].addr = v[1].strip()
		elif not ignoreblock and cur > -1 and v[0].find(param_val) > -1:
			elems[cur].val = v[1].strip()

def getOscElem(i):
	for e in elems:
		if e.mtype == midi_osc and e.id == i:
			return e

for e in elems:
	if e.mtype == midi_adsr:
		o = getOscElem(e.id)
		o.aaddr = e.addr
	elif e.mtype == midi_vel:
		o = getOscElem(e.id)
		o.vaddr = e.addr

w = open(r'\Users\john-mchugh\Documents\Analog Devices\SigmaStudio 4.5\RPI\params\paramsxml.txt', 'w')
w.write('  <beometa>\n')

def eqq(v):
	return "='" + v + "'"	

for e in elems:
	if not e.writeXML:
		continue
	print(e.mtype, e.id, e.min, e.max, e.format, "addr", e.addr, "vel", e.vaddr, "adsr", e.aaddr)
	msg = "    <metadata synth" + eqq(e.mtype) + " " + adsr_addr + " " + eqq(e.aaddr) + " " + vel_addr + eqq(e.vaddr)
	msg = msg + " min" + eqq(e.min) + " max" + eqq(e.max) + " format" + eqq(e.format) + " midi_id" + eqq(e.id)
	msg = msg + ">" + e.addr + "</metadata>\n"
	w.write(msg)
w.write('  </beometa>')
	
		