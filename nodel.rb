class Tempfile
	alias_method :old_initialize, :initialize
  def initialize(basename, tmpdir=Dir::tmpdir, unlink_finalize = true)
		old_initialize(basename, tmpdir)
		ObjectSpace.undefine_finalizer(self) if not unlink_finalize
	end
end
