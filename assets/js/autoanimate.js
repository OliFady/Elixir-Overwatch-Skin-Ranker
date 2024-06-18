import autoAnimate from "@formkit/auto-animate";

let AutoAnimateHook = {
  mounted() {
    autoAnimate(this.el);
  },
};
export default AutoAnimateHook
