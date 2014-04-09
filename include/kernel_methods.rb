module ::Kernel
  def _(str, replaces = nil)
    return $gettext_simple_kernel_instance.translate(str, replaces)
  end
end
