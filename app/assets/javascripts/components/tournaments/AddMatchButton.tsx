import * as React from "react";
import { Button, DatePicker, Form, Input, message, Modal } from "antd";
import TournamentRequests from "../../api/requests/TournamentRequests";
import Api from "../../api/Api";
import Tournament from "../../entities/Tournament";
import { authenticated } from "../../helpers/AuthenticationHOC";
import MatchRequests from "../../api/requests/MatchRequests";
import { Match } from "../../entities/Match";

interface AddButtonProps {
  tournamentId?: number;
}

function AddMatchButton({ tournamentId }: AddButtonProps) {
  const [isFormVisible, setFormVisible] = React.useState(false);
  const [isWorking, setWorking] = React.useState(false);

  const [form] = Form.useForm();

  React.useEffect(() => {
    if (!isFormVisible)
      form.resetFields();
  }, [isFormVisible]);

  const showModal = () => setFormVisible(true);
  const hideModal = () => setFormVisible(false);

  const createTournament = async (values) => {
    setWorking(true);

    try {
      const request = MatchRequests.createMatch({
        tournamentId,
        matchId: values.matchId,
        roundName: values.name,
        blueCaptain: values.blueCaptain,
        redCaptain: values.redCaptain,
        discardList: values.discardList?.split('|').map(d => parseInt(d, 10)) ?? [],
        referees: values.referees?.split('|') ?? [],
      });
      const response = await Api.performRequest<Match>(request);

      message.success(`${response.round_name} created`);

      window.location.href = `/matches/${response.id}`;
    } catch (e) {
      message.error(e.message);
      setWorking(false);
    }
  }

  return (
    <React.Fragment>
      <Button onClick={showModal} type="primary" className="ot-btn">
        <i className="material-icons">add</i>
        <span>Add match</span>
      </Button>
      <Modal
        visible={isFormVisible}
        title="Add match"
        onCancel={hideModal}
        onOk={form.submit}
        confirmLoading={isWorking}
      >
        <Form form={form} onFinish={createTournament} layout="vertical">
          <Form.Item name="name" label="Name" rules={[{ required: true }]}>
            <Input type="text" placeholder="osu!india Winter Tournament" />
          </Form.Item>
          <Form.Item
            name="matchId"
            label="osu! MP ID"
            required={true}
            rules={[{ required: true, type: "number" }]}
            getValueFromEvent={e => parseInt(e.target.value, 10)}
          >
            <Input type="text" placeholder="12345" />
          </Form.Item>
          <Form.Item name="blueCaptain" label="Blue team captain">
            <Input type="text" placeholder="nitr0f" />
          </Form.Item>
          <Form.Item name="redCaptain" label="Red team captain">
            <Input type="text" placeholder="Potla" />
          </Form.Item>
          <Form.Item
            name="discardList"
            label="Discard list"
            help="Pipe (|) separated list of 0-based indices that are to be discarded from the list of maps played in this match"
          >
            <Input type="text" placeholder="0|1|15" />
          </Form.Item>
          <Form.Item
            name="referees"
            label="Referees"
            help="Pipe (|) separated list of players whose scores are to be ignored"
          >
            <Input type="text" placeholder="nitr0f|Potla" />
          </Form.Item>
        </Form>
      </Modal>
    </React.Fragment>
  );
}

export default authenticated(AddMatchButton);
