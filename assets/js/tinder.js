const TRIGGER_WIDTH = 60;
const TRANSFORM_CUTTER = 10;

module.exports = function (el) {
  const hammertime = new Hammer(el, {});
  hammertime.get('pan').set({ direction: Hammer.DIRECTION_HORIZONTAL });

  let starting_x = null;

  hammertime.on('panstart', function (evt) {
    starting_x = evt.center.x;
  });

  hammertime.on('pan', function (evt) {
    const delta = evt.center.x - starting_x,
      direction = (delta < 0 ? "left" : "right"),
      rotation = delta / (screen.width / TRANSFORM_CUTTER);

    el.style.transform = `translate(${delta}px, 0) rotate(${rotation}deg)`;
  });

  hammertime.on('panend', function (evt) {
    const delta = evt.center.x - starting_x,
      direction = (delta < 0 ? "left" : "right");

    if (Math.abs(delta) > TRIGGER_WIDTH) {
      console.log('triggered ' + direction);
      const highlight = document.getElementsByClassName(direction);
      for (let i = 0; i < highlight.length; i++) {
        highlight[i].classList.add('active');
        fadeActive(highlight[i]);
      }
    }

    el.style.transform = `translate(0,0) rotate(0deg)`;
  });
}

function fadeActive(element) {
  setTimeout(() => element.classList.remove('active'), 3000);
}
