package {
    import com.greensock.TweenLite;
    import com.gskinner.utils.Rndm;
    import flash.display.MovieClip;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;

    public class Main extends MovieClip {
        private static const N_PAGES:int = 3;
        private var currentPage:int = 0;
        private var processor:EventProcessor;

        public function Main() {
            stage.scaleMode = StageScaleMode.SHOW_ALL;

            updatePage();

            btnNext.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                updatePage(1);
            });
            btnPrev.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void {
                updatePage(-1);
            });

            ui.btnSimulate.addEventListener(MouseEvent.CLICK, simulate);
            ui.btnPlayPause.addEventListener(MouseEvent.CLICK, pauseUnpause);
            ui.btnNextEvent.addEventListener(MouseEvent.CLICK, nextEvent);

            ui.numRandomSeed.value = ui.numRandomSeed.maximum * Math.random();
            ui.cacheAsBitmap = true;
        }

        private function nextEvent(e:MouseEvent):void {
            processor.nextEvent();
        }

        private function simulate(e:MouseEvent):void {
            Rndm.seed = ui.numRandomSeed.value;
            EventProcessor.SPEED = ui.numSpeed.value;

            currentPage = N_PAGES;
            updatePage();

            Tower.maxDuration = 0;
            Tower.minDuration = int.MAX_VALUE;
            Tower.totalDuration = 0;

            Tower.maxOccupation = 0;
            Tower.minOccupation = int.MAX_VALUE;
            Tower.totalOccupation = 0;

            Tower.all = [new Tower(), new Tower(), new Tower()];
            Tower.all[0].addNeighbors(Tower.all[1], Tower.all[2]);
            Tower.all[0].x = 200;
            Tower.all[0].y = 150;
            Tower.all[1].addNeighbors(Tower.all[0], Tower.all[2]);
            Tower.all[1].x = 600;
            Tower.all[1].y = 150;
            Tower.all[2].addNeighbors(Tower.all[0], Tower.all[1]);
            Tower.all[2].x = 400;
            Tower.all[2].y = -Tower.all[2].height;

            var events:Array = [];
            Tower.all[0].generateEvents(ui.configC1, ui.numTotalCalls.value / 2, events);
            Tower.all[1].generateEvents(ui.configC2, ui.numTotalCalls.value / 2, events);
            events.sortOn("time", Array.NUMERIC | Array.DESCENDING);

            processor = new EventProcessor(events, update);
            processor.x = currentPage * stage.stageWidth;
            ui.addChild(processor);
            processor.play();
        }

        private function update():void {
            ui.txtEventsLeft.text = processor.eventStack.length;
            ui.txtTime.text = int(processor.time);

            ui.txtTotal.text = Tower.all[0].totalCalls + Tower.all[1].totalCalls;
            ui.txtCompleted.text = getStatistic(Tower.all[0].completedCalls + Tower.all[1].completedCalls);

            ui.txtLostTower1.text = getStatistic(Tower.all[0].lostCalls);
            ui.txtLostTower2.text = getStatistic(Tower.all[1].lostCalls);
            ui.txtLeft.text = getStatistic(Tower.all[2].lostCalls);

            ui.txtMinDuration.text = int(Tower.minDuration) + " min";
            ui.txtMeanDuration.text = int(Tower.totalDuration / (Tower.all[0].completedCalls + Tower.all[1].completedCalls)) + " min";
            ui.txtMaxDuration.text = int(Tower.maxDuration) + " min";

            ui.txtMinCalls.text = Tower.minOccupation;
            ui.txtMaxCalls.text = Tower.maxOccupation;
            ui.txtMeanCalls.text = int(Tower.totalOccupation / processor.time);

            var totalCapacity:int = Tower.all[0].maxChannels + Tower.all[1].maxChannels;
            ui.txtMinOccupation.text = 100 * (Tower.minOccupation / totalCapacity) + "%";
            ui.txtMaxOccupation.text = 100 * (Tower.maxOccupation / totalCapacity) + "%";
            ui.txtMeanOccupation.text = int((100 * Tower.totalOccupation / processor.time) / totalCapacity) + "%";

            ui.txtOccupation.text = int(100 * (Tower.all[0].channels.length + Tower.all[1].channels.length) / totalCapacity) + "%";
        }

        private function getStatistic(partialCalls:int):String {
            return partialCalls + " (" + int(partialCalls * 100 / (Tower.all[0].totalCalls + Tower.all[1].totalCalls)) + "%)"
        }

        private function pauseUnpause(event:MouseEvent):void {
            if (ui.btnPlayPause.selected)
                processor.pause();
            else
                processor.resume();
        }

        private function updatePage(offset:int = 0):void {
            if (processor) {
                processor.pause();
                ui.removeChild(processor);
                processor = null;
            }

            currentPage += offset;
            btnPrev.enabled = currentPage > 0;
            btnNext.enabled = currentPage < N_PAGES - 1;
            TweenLite.to(ui, 0.5, { x: -stage.stageWidth * currentPage } );
        }
    }

}